# Bygg och distribuera en webapp med Docker och Github Actions

Detta projekt består av en enkel webbapplikation byggd med PHP och Nginx som körs i en Docker-container. Applikationen är ett kontaktformulär för företaget Wavvy AB där användare kan skicka meddelanden till företagets support. Frontend är stilren och responsiv med CSS, och efter inskickat formulär visas ett bekräftelsemeddelande.

Docker-imagen baseras på PHP 8.2 med PHP-FPM och Nginx, och applikationen är konfigurerad för att köra PHP via FastCGI. Applikationen körs tillsammans med en omvänd proxy (nginx-proxy) som hanterar inkommande trafik och vidarebefordrar den till rätt container. SSL-certifikat hanteras automatiskt via Let's Encrypt och en certifikatkompanjon.

Hela bygg- och deployprocessen är automatiserad med GitHub Actions. Vid varje push till master-grenen byggs en ny Docker-image, pushas till Docker Hub och deployas via SSH till en server där Docker Compose startar om containrarna med den nya versionen. Miljövariabler för domän och certifikat hanteras säkert via GitHub Secrets.

GitHub Repo: https://github.com/91maxore-hub/php-app

🛠️ Steg 1 – Skapandet av projektstruktur och grundfiler

| Fil / Mapp      | Typ  | Beskrivning                       |
| --------------- | ---- | --------------------------------- |
| `php-app/`      | Mapp | Projektets rotmapp                |
| ├── `index.php` | Fil  | Huvudfil för webbapplikationen    |
| ├── `style.css` | Fil  | CSS-stilmall för sidans utseende  |
| └── `logo2.png` | Fil  | Bildfil – logotyp för webbplatsen |

Syftet med dessa filer var att skapa en minimal men fungerande webbsida som kunde paketeras i en Docker-image. index.php innehåller själva innehållet för sidan, style.css står för designen, och logo2.png används logobild för webbplatsen.

Steg 2: Paketera som Docker Image och ladda upp till Docker Hub

Efter att projektstrukturen var klar (med index.php, style.css, logo2.png), gick jag vidare till att paketera projektet i en Docker-image och publicera den på Docker Hub.
Jag började först med att skapa ett repo på Docker Hub som ska hålla min Docker-image som jag döpte till **php-nginx-app**

![alt text](image.png)

Jag skapade därefter en Dockerfile som installerar PHP 8.2 med FPM, Nginx, och kopierar in mina filer samt en egen Nginx-konfiguration:

```Dockerfile
# Använd officiell PHP 8.2 FPM image som bas (PHP med FastCGI Process Manager)
FROM php:8.2-fpm

# Uppdatera paketlistan och installera Nginx webbserver
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  # Rensa cache för att hålla image liten

# Ta bort standardfiler i Nginx webbroot för att undvika att visa standardstartsidan
RUN rm -rf /var/www/html/*

# Kopiera applikationens filer från din dator till containerns webbrot
COPY . /var/www/html

# Byt arbetskatalog till webbrot, där index.php ligger
WORKDIR /var/www/html

# Kopiera din egen Nginx-konfiguration till standardplats
COPY default.conf /etc/nginx/sites-available/default

# Exponera port 80 för webbtrafik utanför containern
EXPOSE 80

# Starta php-fpm i bakgrunden och nginx i förgrunden
CMD ["bash", "-c", "php-fpm & nginx -g 'daemon off;'"]
```

Jag skapade även en fil default.conf där jag konfigurerade Nginx att peka på rätt katalog och hantera PHP-filer.

```default.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass 127.0.0.1:9000;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

Byggandet av Docker Image
I terminalen körde jag följande kommando i projektmappen (där mina samtliga filer finns) för att bygga mina projektfiler till en Docker Image

```bash
docker build -t 91maxore/php-nginx-app:latest .
```

Loggade in på Docker Hub
Jag loggade in med:
```bash
docker login
```

Och angav mitt användarnamn och lösenord som jag använder till Docker Hub.

🚀 Pushade Docker Image till Docker Hub
```bash
docker push 91maxore/php-nginx-app:latest
```

Detta pushar min nyskapade Docker Image till Docker Hub och är redo för användning.
Nu ligger den på Docker Hub:

🔗 https://hub.docker.com/repository/docker/91maxore/php-nginx-app/

**Köra containern lokalt**
För att först testa att containern fungerar som den ska, körde jag den med:
```bash
docker run -d -p 8080:80 91maxore/php-nginx-app:latest
```

Notera: Att jag kör Docker imagen mot port 8080

Sedan kunde jag öppna webappen i webbläsaren via:
```bash
http://localhost:8080
```

Där laddades min PHP-webapp utan konstigheter.

![alt text](image-1.png)

**Steg 3: Köra i en Container Host**

Efter att jag byggt och laddat upp Docker-imagen till Docker Hub var nästa steg att köra webappen i en container på en containerhost.

Jag testade detta lokalt (som du kan läsa ovan) och det fungerade. Så nästa steg är att få en Azure VM att köra containern, så att appen kan nås därifrån via sitt publika IP hela tiden.

**Konfiguration av Container Host**

| **Parameter**  | **Värde**                          |
| -------------- | ---------------------------------- |
| **Namn**       | PHP-APP-VM                         |
| **Region**     | North Europe                       |
| **Image**      | Ubuntu Server 22.04 LTS – x64 Gen2 |
| **Storlek**    | Standard\_B1s (1 vCPU, 1 GiB RAM)  |
| **Publikt IP** | 4.231.236.186                      |

Steg 1: Logga in på servern via SSH:
```bash
ssh -i ~/Downloads/php-VM_key.pem azureuser@4.231.236.186
```

Steg 2: Installera Docker:
```bash
sudo apt update
sudo apt install docker.io -y
```

Steg 3: Kör containern:
```bash
docker run -d -p 80:80 91maxore/php-nginx-app:latest
```

Notera att jag inte behövde utföra docker login eftersom docker imagen är publik.
Dessutom kör vi containern på port 80 så att man slipper ange porten efter ip-adressen.

Steg 4: Gå till serverns IP-adress i webbläsaren:
```bash
http://4.231.236.186
```

![alt text](image-2.png)

Notera att appen är åtkomlig via serverns publika IP.
Det är viktigt att notera att port 80 (för HTTP) behöver vara öppen i brandväggen på Azure.

🔄 Kontrollera att containern körs
För att se om containern är igång kan du använda:

```bash
docker ps
```

Du ser då något liknande:

![alt text](image-3.png)

Nu har jag flera container som körs eftersom jag kör reverse proxy + HTTPS/SSL. Men dit kommer vi senare, men du förstår poängen.

För att stoppa och ta bort containern, kan du utföra följande:
```bash
docker stop <container-id>
docker rm <container-id>
```

Tänk på att du kan behöva använda sudo om du inte har root-permissions.

🌐 Steg 4: Använda domännamn istället för IP (wavvy.se via Loopia)

För att göra webappen tillgänglig via ett eget domännamn, valde jag att koppla domänen wavvy.se, som jag köpt via Loopia, till min server istället för att använda en publik IP-adress direkt. Främst eftersom jag inte vill exponera serverns publika IP.

Jag loggade in på Loopia och gick till DNS-inställningarna för domänen. Där uppdaterade jag A-posten så att wavvy.se pekar på min servers publika IP-adress. Efter en stund kunde appen nås via http://wavvy.se

![alt text](image-4.png)

🔁 Steg 5: Reverse Proxy och HTTPS med Docker + Let's Encrypt

För att säkra min webbapp och göra den tillgänglig via HTTPS, satte jag upp en reverse proxy med automatiskt SSL-certifikat från Let's Encrypt.

**Jag använde tre containrar:**

1. Min php-nginx-app (från Docker Hub)
2. nginx-proxy – reverse proxy som lyssnar på trafik och omdirigerar till rätt container
3. letsencrypt-nginx-proxy-companion – genererar och hanterar SSL-certifikat automatiskt

🧱 docker-compose.yml

Jag skapade en docker-compose.yml som definierade alla tre containrar:

```yaml
version: '3'

services:
  app:
    image: 91maxore/php-nginx-app:latest
    container_name: my-php-app
    restart: unless-stopped
    expose:
      - "80"
    environment:
      - VIRTUAL_HOST=${VIRTUAL_HOST}
      - LETSENCRYPT_HOST=${LETSENCRYPT_HOST}
      - LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
    networks:
      - webnet

  reverse-proxy:
    image: jwilder/nginx-proxy
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs:ro
      - ./vhost.d:/etc/nginx/vhost.d
      - ./html:/usr/share/nginx/html
    networks:
      - webnet

  letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: nginx-proxy-acme
    restart: unless-stopped
    environment:
      - NGINX_PROXY_CONTAINER=nginx-proxy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./certs:/etc/nginx/certs:rw
      - ./vhost.d:/etc/nginx/vhost.d
      - ./html:/usr/share/nginx/html
    networks:
      - webnet

networks:
  webnet:
    driver: bridge
```

**🔐 Automatisk HTTPS med miljövariabler**

För att konfigurera SSL och domännamnet använde jag tre miljövariabler som app-containern läser in:

1. VIRTUAL_HOST – domännamnet (wavvy.se)
2. LETSENCRYPT_HOST – domännamnet som certifikatet ska utfärdas för (wavvy.se)
3. LETSENCRYPT_EMAIL – min e-postadress för Let's Encrypt (91maxore@gafe.molndal.se)

Dessa värden sattes i en .env-fil, som genereras automatiskt av GitHub Actions under deployment.

**🚀 Automatiserad deploy med GitHub Actions**

För att förenkla processen byggde och pushade jag min Docker-image automatiskt via GitHub Actions, och deployade sedan direkt till servern via SSH.

Workflow-filen (.github/workflows/docker-image.yml) gör följande:

1. Bygger Docker-imagen
2. Pushar den till Docker Hub
3. Ansluter till servern via SSH
4. Skapar .env-fil med hjälp av GitHub Secrets
5. Startar eller uppdaterar containrarna med docker-compose up -d

Nedan är ett utdrag som gör just detta jag nämnde precis.

```yaml
- name: 🚀 Deploya till server
  uses: appleboy/ssh-action@v0.1.7
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    key: ${{ secrets.SERVER_SSH_KEY }}
    script: |
      cd /home/azureuser/nginx-reverse-proxy

      echo "VIRTUAL_HOST=${{ secrets.VIRTUAL_HOST }}" > .env
      echo "LETSENCRYPT_HOST=${{ secrets.LETSENCRYPT_HOST }}" >> .env
      echo "LETSENCRYPT_EMAIL=${{ secrets.LETSENCRYPT_EMAIL }}" >> .env

      sudo docker-compose pull
      sudo docker-compose up -d
```

Jag lagrar alla känsliga värden (IP, domän, SSH-nyckel, e-post) som GitHub Secrets i repo-inställningarna.

![alt text](image-5.png)

| 🔒 **Secret**        | 💬 **Beskrivning / Värde**                                                            |
| -------------------- | -------------------------------------------------------------------------------------- |
| `DOCKERHUB_USERNAME` | **Användarnamn för Docker Hub** – `91maxore`                                           |
| `DOCKERHUB_TOKEN`    | **Access token för Docker Hub**                                                        |
| `SERVER_HOST`        | **Serverns IP-adress** – `4.231.236.186`                                               |
| `SERVER_USER`        | **Användare för SSH-anslutning till servern** – `azureuser`                            |
| `SERVER_SSH_KEY`     | **Privat SSH-nyckel** – används av GitHub Actions för att logga in på servern via SSH  |
| `VIRTUAL_HOST`       | **Domännamn för webbappen** – `wavvy.se`                                               |
| `LETSENCRYPT_HOST`   | **Domän för SSL-certifikat (Let's Encrypt)** – `wavvy.se`                              |
| `LETSENCRYPT_EMAIL`  | **E-postadress för certifikatregistrering och förnyelse** – `91maxore@gafe.molndal.se` |


✅ Resultat

Efter att allt var uppsatt kunde jag gå till:
🔗 https://wavvy.se

Min PHP-webapp laddas med giltigt SSL-certifikat, automatisk HTTPS och reverse proxy som hanterar trafiken smidigt.
Allt detta sker helt automatiskt – både deployment och certifikatförnyelse.
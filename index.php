<!DOCTYPE html>
<html lang="sv">
<head>
    <meta charset="UTF-8">
    <title>Kontaktformulär</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="form-container">

        <!-- Företagslogotyp -->
        <img src="logo2.png" alt="Företagets logotyp" class="company-logo">

        <!-- Företagsinfo-ruta -->
        <div class="info-container">
            <h3>🏢 Om Wavvy AB – Din digitala partner</h3>
            <p><strong>Wavvy AB</strong> är din digitala partner inom webbutveckling och IT. Sedan 2010 har vi hjälpt företag att växa, effektivisera och lyckas i en allt mer digital värld.</p>

            <p>🌐 <strong>Webbdesign & webbutveckling:</strong><br>
            Vi skapar moderna, responsiva webbplatser med fokus på användarupplevelse, design och funktionalitet – alltid med ditt varumärke i centrum.</p>

            <p>🛠️ <strong>Systemutveckling:</strong><br>
            Vi skapar innovativa och anpassade mjukvarulösningar som möter dina specifika behov och hjälper din verksamhet att växa och bli mer effektiv.</p>

            <p>🖥️ <strong>IT-support & drift:</strong><br>
            Få pålitlig support och säker drift av din IT-miljö – vi hjälper till både på distans och på plats när du behöver det.</p>

            <p>☁️ <strong>Molntjänster:</strong><br>
            Vi erbjuder flexibla molnlösningar såsom Microsoft 365, backup, fjärråtkomst och säkerhetslösningar för moderna arbetsplatser.</p>

            <p><strong>Adress:</strong> Exempelgatan 123, 123 45 Stad<br>
            <strong>E-post:</strong> info@wavvy.se</p>

            <hr style="margin: 15px 0; border: none; border-top: 1px solid #ddd;">

            <h4 style="margin-bottom: 5px;">Behöver du hjälp?</h4>
            <p>Om du har tekniska problem eller frågor, vänligen använd kontaktformuläret nedan för att nå vår support.</p>
        </div>

        <h2>✉️ Kontakta oss</h2>
        <form method="POST">
            <input type="text" name="namn" placeholder="Ditt namn" required>
            <input type="email" name="epost" placeholder="Din e-post" required>
            <textarea name="meddelande" placeholder="Ditt meddelande" required></textarea>
            <button type="submit">Skicka</button>
        </form>

        <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            $namn = htmlspecialchars($_POST['namn']);
            echo "<div class='thanks' id='thanksMessage'>
                    ✅ Tack för ditt meddelande, $namn!<br>
                    Vår supportavdelning har tagit emot ditt ärende och kommer att behandla det så snart som möjligt.
                  </div>";
        }
        ?>

    </div>

    <script>
        window.onload = function() {
            const thanksMsg = document.getElementById('thanksMessage');
            if (thanksMsg) {
                thanksMsg.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        };
    </script>
</body>
</html>
document
  .getElementById("loginForm")
  .addEventListener("submit", async function (event) {
    event.preventDefault(); // Evita el comportamiento predeterminado del formulario

    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    // Crea el objeto para enviar a la función Lambda
    const requestBody = {
      operation: "login",
      email: email,
      contrasena: password,
    };

    try {
      const response = await fetch(
        "https://4q4xda75oq2zwljjtjkooxrnme0fhccm.lambda-url.us-west-2.on.aws/",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(requestBody),
        }
      );

      const data = await response.json();

      // Muestra el mensaje de respuesta
      const responseMessage = document.getElementById("responseMessage");
      if (response.ok) {
        responseMessage.style.color = "green";
        responseMessage.textContent = data.message; // Mensaje de éxito
      } else {
        responseMessage.style.color = "red";
        responseMessage.textContent = data.message; // Mensaje de error
      }
    } catch (error) {
      console.error("Error:", error);
      document.getElementById("responseMessage").textContent =
        "Error al comunicarse con el servidor.";
    }
  });

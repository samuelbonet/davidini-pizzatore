document.getElementById("user-form").addEventListener("submit", function (e) {
  e.preventDefault(); // Evita el comportamiento predeterminado del formulario

  // Obtener los valores del formulario
  const email = document.getElementById("email").value;
  const nombre = document.getElementById("nombre").value;
  const apellido = document.getElementById("apellido").value;
  const contrasena = document.getElementById("contrasena").value;

  // Crear el objeto que será enviado en la solicitud
  const userData = {
    operation: "insert",
    email: email,
    nombre: nombre,
    apellido: apellido,
    contrasena: contrasena,
  };

  // Hacer la solicitud POST a la función Lambda
  fetch(
    "https://4q4xda75oq2zwljjtjkooxrnme0fhccm.lambda-url.us-west-2.on.aws/",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(userData),
    }
  )
    .then((response) => response.json())
    .then((data) => {
      // Mostrar la respuesta en la página
      document.getElementById("response").innerText =
        "Usuario registrado con éxito";
      console.log(data);
    })
    .catch((error) => {
      // Manejar errores
      document.getElementById("response").innerText =
        "Hubo un error al registrar el usuario";
      console.error("Error:", error);
    });
});

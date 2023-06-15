var cartButton = document.getElementById("btn-prch");
cartButton.addEventListener("click", openModal2);

var cartButton = document.getElementById("btn-hm");
cartButton.addEventListener("click", clearCart, closeModal2);

// Function to handle opening the cart modal
function openModal2() {
    var modal = document.getElementById("scsModal");
    modal.style.display = "block";
  }

  function closeModal2() {
    var modal = document.getElementById("scsModal");
    var modal1 = document.getElementById("cartModal");
    modal.style.display = "none";
    modal1.style.display="none";
  }
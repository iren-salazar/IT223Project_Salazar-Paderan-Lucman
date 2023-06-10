// Get all the buttons with the class "AddtoCart"
var addToCartBtns = document.querySelectorAll('.AddtoCart');

// Get the cartCount element
var cartCountElement = document.getElementById('cartCount');

// Initialize the cart count
var cartCount = 0;

// Add event listener to each button
addToCartBtns.forEach(function(button) {
  button.addEventListener('click', function() {
    cartCount++;
    cartCountElement.textContent = cartCount;
  });
});

var addToCartBtns = document.querySelectorAll('.AddtoCart');
var cartCountElement = document.getElementById('cartCount');
var cartItemsElement = document.getElementById('cartItems');
var cartCount = 0;
var cartItems = [];

addToCartBtns.forEach(function(button) {
  button.addEventListener('click', function() {                                                 // Code executed when a button is clicked
    var productElement = button.closest('.showcase');                                           // Find the closest ancestor element with the class "showcase"
    var productName = productElement.querySelector('.showcase-title').textContent;              // Get the text content of the element 
    var productPrice = parseFloat(productElement.querySelector('.price').textContent);          // - with the class "showcase-title" within the productElement
    var productQuantity = 1;

    // Update cart count
    cartCount++;
    cartCountElement.textContent = cartCount;

    // Check if the product already exists in the cart
    var existingProduct = cartItems.find(function(item) {
      return item.name === productName;
    });

    if (existingProduct) {
      // If the product already exists, update its quantity
      existingProduct.quantity += productQuantity;
    } else {
      // If the product is new, add it to the cart
      var newProduct = {
        name: productName,
        price: productPrice,
        quantity: productQuantity
      };
      cartItems.push(newProduct);
    }

    // Update cart items display
    renderCartItems();
  });
});

function renderCartItems() {
  // Clear the cart items display
  cartItemsElement.innerHTML = '';

  // Render each item in the cart
  cartItems.forEach(function(item) {
    var cartItemElement = document.createElement('li');
    cartItemElement.textContent = item.name + ' x' + item.quantity;
    cartItemsElement.appendChild(cartItemElement);
  });
}

// Clear cart items from storage on page load
window.addEventListener("load", function () {
  localStorage.removeItem("cartItems");
});

// Retrieve cart items from storage and display them in the modal
var cartItems = JSON.parse(localStorage.getItem("cartItems")) || [];
var cartItemsList = document.getElementById("cartItemsList");
var totalAmount = document.querySelector(".total");

// Function to handle opening the cart modal
function openModal1() {
  var modal = document.getElementById("cartModal");
  modal.style.display = "block";
  updateCartDisplay();
}

// Function to handle closing the cart modal
function closeModal1() {
  var modal = document.getElementById("cartModal");
  modal.style.display = "none";
}

// Add event listener to the cart button to open the modal
var cartButton = document.getElementById("OpenCart");
cartButton.addEventListener("click", openModal1);

var cartButton = document.getElementById("OpenCart_mbl");
cartButton.addEventListener("click", openModal1);

// Update the cart display when a new item is added
function addToCart(item) {
  var existingItem = cartItems.find(function (cartItem) {
    return cartItem.name === item.name;
  });

  if (existingItem) {
    existingItem.quantity++;
  } else {
    cartItems.push({ name: item.name, quantity: 1, price: item.price });
  }

  localStorage.setItem("cartItems", JSON.stringify(cartItems));
  updateCartDisplay();
}

// Update the quantity of an item in the cart
function updateItemQuantity(item, newQuantity) {
  var existingItem = cartItems.find(function (cartItem) {
    return cartItem.name === item.name;
  });

  if (existingItem) {
    existingItem.quantity = newQuantity;
    localStorage.setItem("cartItems", JSON.stringify(cartItems));
    updateCartDisplay();
  }
}

// Update the cart display
function updateCartDisplay() {
  // Clear existing cart items
  cartItemsList.innerHTML = "";

  // Add cart items to the modal and calculate total price
  var totalPrice = 0;
  cartItems.forEach(function (item) {
    var listItem = document.createElement("li");
    listItem.classList.add("cart-item");

    var bulletPoint = document.createElement("span");
    bulletPoint.innerHTML = "&#8226;"; // Unicode for bullet point symbol
    listItem.appendChild(bulletPoint);

    var itemName = document.createElement("strong");
    itemName.textContent = item.name;
    listItem.appendChild(itemName);

    var itemDetails = document.createElement("div");
    itemDetails.classList.add("item-details");

    var quantitySelect = document.createElement("select");
    quantitySelect.addEventListener("change", function (event) {
      var newQuantity = parseInt(event.target.value);
      updateItemQuantity(item, newQuantity);
    });

    // Create options for quantity dropdown
    for (var i = 1; i <= 30; i++) {
      var option = document.createElement("option");
      option.value = i;
      option.textContent = i;
      quantitySelect.appendChild(option);
    }

    // Set the selected quantity for the item
    quantitySelect.value = item.quantity;

    var itemPrice = document.createElement("span");
    itemPrice.textContent = "Price: $" + (item.price * item.quantity).toFixed(2);

    itemDetails.appendChild(quantitySelect);
    itemDetails.appendChild(document.createTextNode("  ")); // Add space
    itemDetails.appendChild(itemPrice);

    listItem.appendChild(document.createTextNode("  ")); // Add space
    listItem.appendChild(itemDetails);
    cartItemsList.appendChild(listItem);

    totalPrice += item.price * item.quantity;
  });

  // Display total price and order summary
  totalAmount.innerHTML =
    "Order Summary<br><span style='font-size: 30px; font-weight: normal;'>Subtotal: $" +
    totalPrice.toFixed(2) +
    "</span>";
}

// Function to clear the cart and refresh the page
function clearCart() {
  localStorage.removeItem("cartItems"); // Remove cart items from storage
  location.reload(); // Refresh the page
}

// Example usage: clearCart();

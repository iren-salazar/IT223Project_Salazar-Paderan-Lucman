// Function to handle opening the cart modal
function openModal() {
  var modal = document.getElementById("cartModal");
  modal.style.display = "block";
}

// Function to handle closing the cart modal
function closeModal() {
  var modal = document.getElementById("cartModal");
  modal.style.display = "none";
}

// Add event listener to the cart button to open the modal
var cartButton = document.getElementById("OpenCart");
cartButton.addEventListener("click", openModal);

// Retrieve cart items from storage and display them in the modal
var cartItems = JSON.parse(localStorage.getItem("cartItems")) || [];
var cartItemsList = document.getElementById("cartItemsList");

function updateCartDisplay() {
  // Clear existing cart items
  cartItemsList.innerHTML = "";

  // Add cart items to the modal
  cartItems.forEach(function (item) {
    var listItem = document.createElement("li");
    listItem.textContent =
      item.name +
      " - Quantity: " +
      item.quantity +
      " - Price: $" +
      (item.price * item.quantity).toFixed(2);
    cartItemsList.appendChild(listItem);
  });
}

// Update the cart display when the modal opens
cartButton.addEventListener("click", updateCartDisplay);

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

// Example usage: addToCart({ name: "Product 1", price: 19.99 });

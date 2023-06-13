// Retrieve the search input field and the items to be searched
var searchField = document.querySelector(".search-field");
var items = document.querySelectorAll(".showcase-title");

// Function to handle the search functionality
function searchItems() {
  var searchTerm = searchField.value.toLowerCase();

  // Loop through each item and check if it matches the search term
  items.forEach(function (item) {
    var itemName = item.querySelector(".item-name").textContent.toLowerCase();
    if (itemName.includes(searchTerm)) {
      item.style.display = "block";
    } else {
      item.style.display = "none";
    }
  });
}

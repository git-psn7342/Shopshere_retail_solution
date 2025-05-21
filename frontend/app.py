<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>ShopSphere Store</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .product { margin-bottom: 15px; }
  </style>
</head>
<body>
  <h1>Welcome to ShopSphere</h1>
  <div id="products"></div>

  <h2>Place Order</h2>
  <form id="orderForm">
    <label for="productId">Product ID:</label>
    <input type="text" id="productId" required><br><br>
    <label for="customer">Customer Name:</label>
    <input type="text" id="customer" required><br><br>
    <button type="submit">Order Now</button>
  </form>

  <p id="result"></p>

  <script>
    // Load products
    fetch('http://localhost:8080/products') // replace with your API URL if deployed
      .then(res => res.json())
      .then(data => {
        const container = document.getElementById('products');
        data.forEach(product => {
          const div = document.createElement('div');
          div.className = 'product';
          div.textContent = `${product.name} - $${product.price} (ID: ${product.id})`;
          container.appendChild(div);
        });
      });

    // Submit order
    document.getElementById('orderForm').addEventListener('submit', async (e) => {
      e.preventDefault();
      const productId = document.getElementById('productId').value;
      const customer = document.getElementById('customer').value;

      const response = await fetch('http://localhost:8080/order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ product_id: productId, customer })
      });

      const result = await response.json();
      document.getElementById('result').textContent = result.message || result.error;
    });
  </script>
</body>
</html>

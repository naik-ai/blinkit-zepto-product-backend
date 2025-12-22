# Blinkit & Zepto Product Comparison API

A Node.js API server that searches and compares grocery product prices between two Indian quick-commerce platforms: **Zepto** and **Blinkit**.

## Features

- 🔍 **Product Search** - Search products across both Zepto and Blinkit simultaneously
- 📍 **40+ Locations** - Pre-mapped coordinates for Mumbai, Virar, Delhi, Bangalore & more
- 🌐 **Dual Mode** - Demo mode (mock data) and Live mode (real API calls)
- ⚡ **Parallel Requests** - Concurrent API calls for faster response
- 💰 **Location-Based Pricing** - Simulates regional price variations
- 📦 **10 Product Categories** - Milk, bread, rice, eggs, sugar, oil, atta, dal, vegetables, snacks

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Node.js | Runtime environment |
| Express.js | Web framework |
| cors | Cross-origin resource sharing |
| body-parser | JSON request parsing |

---

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/blinkit-zepto-product-backend.git
cd blinkit-zepto-product-backend

# Install dependencies
npm install
```

---

## Usage

### Start the Server

```bash
# Demo mode (uses mock data - works offline)
node server.js

# Live mode (real API calls to Zepto/Blinkit - requires internet)
USE_REAL_API=true node server.js

# Custom port
PORT=8080 node server.js
```

---

## API Endpoints

### 1. Search Products

**`POST /search-all`**

Search for products on both Zepto and Blinkit.

**Request Body:**
```json
{
  "location": "Mumbai",
  "product": "milk"
}
```

**With exact coordinates:**
```json
{
  "product": "milk",
  "latitude": 19.0760,
  "longitude": 72.8777
}
```

**Response:**
```json
{
  "zepto": [
    {
      "name": "Amul Taaza Toned Fresh Milk",
      "weight": "1 L",
      "price": "₹66",
      "image": "https://cdn.grofers.com/...",
      "source": "zepto",
      "availability": "In Stock"
    }
  ],
  "blinkit": [
    {
      "name": "Amul Taaza Toned Fresh Milk",
      "weight": "1 L",
      "price": "₹66",
      "image": "https://cdn.grofers.com/...",
      "source": "blinkit",
      "availability": "In Stock"
    }
  ],
  "location": {
    "name": "Mumbai",
    "coordinates": {
      "lat": 19.076,
      "lng": 72.8777
    }
  },
  "mode": "demo"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/search-all \
  -H "Content-Type: application/json" \
  -d '{"location": "Virar", "product": "rice"}'
```

---

### 2. Health Check

**`GET /health`**

Check server status and current mode.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-12-22T18:00:00.000Z",
  "mode": "demo"
}
```

---

### 3. List Locations

**`GET /locations`**

Get all supported locations.

**Response:**
```json
{
  "locations": ["andheri", "bandra", "borivali", "mumbai", "virar", ...],
  "count": 40
}
```

---

### 4. List Categories

**`GET /categories`**

Get available product categories (demo mode).

**Response:**
```json
{
  "categories": ["milk", "bread", "rice", "eggs", "sugar", "oil", "atta", "dal", "vegetables", "snacks"],
  "mode": "demo"
}
```

---

### 5. Test Location

**`GET /test-location/:location`**

Test coordinate resolution for a location name.

**Example:** `GET /test-location/virar`

**Response:**
```json
{
  "location": "virar",
  "coordinates": {
    "lat": 19.4559,
    "lng": 72.8111
  }
}
```

---

## Supported Locations

### Mumbai Metropolitan Region
| Area | Coordinates |
|------|-------------|
| Mumbai (Central) | 19.0760, 72.8777 |
| Andheri West | 19.1360, 72.8296 |
| Andheri East | 19.1136, 72.8697 |
| Bandra | 19.0596, 72.8295 |
| Powai | 19.1176, 72.9060 |
| Dadar | 19.0176, 72.8426 |
| Borivali | 19.2307, 72.8567 |
| Malad | 19.1873, 72.8486 |
| Goregaon | 19.1663, 72.8526 |
| Kandivali | 19.2047, 72.8525 |
| Thane | 19.2183, 72.9781 |
| Chembur | 19.0622, 72.8977 |
| Mulund | 19.1726, 72.9563 |
| Ghatkopar | 19.0863, 72.9081 |
| Juhu | 19.1075, 72.8263 |
| Worli | 19.0176, 72.8153 |
| Lower Parel | 19.0048, 72.8305 |

### Virar / Vasai Region
| Area | Coordinates |
|------|-------------|
| Virar | 19.4559, 72.8111 |
| Virar West | 19.4559, 72.7950 |
| Virar East | 19.4559, 72.8200 |
| Nalasopara | 19.4181, 72.8144 |
| Nalasopara West | 19.4181, 72.8000 |
| Nalasopara East | 19.4181, 72.8300 |
| Vasai | 19.3919, 72.8397 |
| Vasai West | 19.3955, 72.8128 |
| Vasai East | 19.3919, 72.8600 |

### Delhi NCR
| Area | Coordinates |
|------|-------------|
| Delhi | 28.6139, 77.2090 |
| Noida | 28.5355, 77.3910 |
| Gurgaon/Gurugram | 28.4595, 77.0266 |
| Faridabad | 28.4089, 77.3178 |
| Ghaziabad | 28.6692, 77.4538 |

### Other Cities
| City | Coordinates |
|------|-------------|
| Bangalore | 12.9716, 77.5946 |
| Koramangala | 12.9352, 77.6245 |
| Indiranagar | 12.9784, 77.6408 |
| Whitefield | 12.9698, 77.7500 |
| Pune | 18.5204, 73.8567 |
| Hyderabad | 17.3850, 78.4867 |
| Chennai | 13.0827, 80.2707 |
| Kolkata | 22.5726, 88.3639 |

---

## Product Categories (Demo Mode)

| Category | Sample Products |
|----------|-----------------|
| `milk` | Amul Taaza, Mother Dairy, Amul Gold, Nestle a+ |
| `bread` | Britannia, Modern, Harvest Gold, English Oven |
| `rice` | India Gate, Daawat, Fortune, Kohinoor, Lal Qilla |
| `eggs` | Fresho Farm Eggs, Nandini Brown Eggs, Keggs |
| `sugar` | India Gate, Uttam, Trust Classic, Tata |
| `oil` | Fortune Sunflower, Saffola Gold, Dhara Mustard |
| `atta` | Aashirvaad, Fortune Chakki, Pillsbury, Patanjali |
| `dal` | Tata Sampann Toor, Fortune Arhar, Moong Dal |
| `vegetables` | Tomato, Onion, Potato, Capsicum, Carrot |
| `snacks` | Lay's, Kurkure, Haldiram's, Parle Monaco, Oreo |

---

## Response Fields

Each product in the response contains:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Product name |
| `weight` | string | Weight/quantity (e.g., "1 L", "500 g") |
| `price` | string | Price with ₹ symbol |
| `image` | string | URL to product image |
| `source` | string | "zepto" or "blinkit" |
| `availability` | string | "In Stock" or "Out of Stock" |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 3000 | Server port |
| `USE_REAL_API` | false | Enable real API calls to Zepto/Blinkit |

---

## Location-Based Pricing

The API simulates regional price variations:
- **Virar/Vasai areas**: 2% higher prices (outskirt markup)
- **Mumbai central**: Base prices

---

## Error Handling

**Missing product parameter:**
```json
{
  "error": "Product is required"
}
```

**API failure (Live mode):**
```json
{
  "error": "Failed to scrape data",
  "details": "Error message"
}
```

---

## Deployment

### Local Development
```bash
npm install
node server.js
```

### Production (with real APIs)
```bash
npm install
USE_REAL_API=true PORT=3000 node server.js
```

### Docker (optional)
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

---

## License

This project is open-source under the MIT License.

---

## Preview

![image](https://github.com/user-attachments/assets/a2844bab-eeba-45d8-9ae3-ba9c22fca8ef)

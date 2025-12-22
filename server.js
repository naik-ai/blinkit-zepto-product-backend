const express = require("express");
const bodyParser = require("body-parser");

const app = express();
const port = process.env.PORT || 3000;

// Set to true to use real API calls (requires network access)
// Set to false for mock data (for testing/demo)
const USE_REAL_API = process.env.USE_REAL_API === "true";

const cors = require("cors");

app.use(cors());
app.use(bodyParser.json());
app.use(express.static("public"));

// Common headers to mimic browser requests
const getCommonHeaders = () => ({
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Accept": "application/json, text/plain, */*",
  "Accept-Language": "en-US,en;q=0.9",
  "Accept-Encoding": "gzip, deflate, br",
});

// Mock grocery data for testing
const mockGroceryProducts = {
  milk: [
    { name: "Amul Taaza Toned Fresh Milk", weight: "1 L", price: "₹66", image: "https://cdn.grofers.com/app/images/products/sliding_image/amul-taaza.jpg" },
    { name: "Mother Dairy Full Cream Milk", weight: "1 L", price: "₹72", image: "https://cdn.grofers.com/app/images/products/mother-dairy-milk.jpg" },
    { name: "Amul Gold Full Cream Milk", weight: "1 L", price: "₹72", image: "https://cdn.grofers.com/app/images/products/amul-gold.jpg" },
    { name: "Nestle a+ Nourish Toned Milk", weight: "1 L", price: "₹68", image: "https://cdn.grofers.com/app/images/products/nestle-milk.jpg" },
    { name: "Gokul Full Cream Milk", weight: "500 ml", price: "₹35", image: "https://cdn.grofers.com/app/images/products/gokul-milk.jpg" },
    { name: "Amul Masti Buttermilk", weight: "1 L", price: "₹40", image: "https://cdn.grofers.com/app/images/products/amul-buttermilk.jpg" },
    { name: "Mother Dairy Cow Milk", weight: "1 L", price: "₹70", image: "https://cdn.grofers.com/app/images/products/mother-dairy-cow.jpg" },
    { name: "Amul Taaza Homogenised Milk", weight: "500 ml", price: "₹33", image: "https://cdn.grofers.com/app/images/products/amul-taaza-500.jpg" },
    { name: "Gowardhan Paneer Milk", weight: "1 L", price: "₹76", image: "https://cdn.grofers.com/app/images/products/gowardhan.jpg" },
    { name: "Nandini Goodlife Toned Milk", weight: "1 L", price: "₹58", image: "https://cdn.grofers.com/app/images/products/nandini-milk.jpg" },
  ],
  bread: [
    { name: "Britannia Whole Wheat Bread", weight: "400 g", price: "₹45", image: "https://cdn.grofers.com/app/images/products/britannia-bread.jpg" },
    { name: "Modern Whole Wheat Bread", weight: "400 g", price: "₹40", image: "https://cdn.grofers.com/app/images/products/modern-bread.jpg" },
    { name: "Harvest Gold White Bread", weight: "450 g", price: "₹42", image: "https://cdn.grofers.com/app/images/products/harvest-gold.jpg" },
    { name: "Britannia Brown Bread", weight: "400 g", price: "₹50", image: "https://cdn.grofers.com/app/images/products/britannia-brown.jpg" },
    { name: "English Oven Sandwich Bread", weight: "350 g", price: "₹55", image: "https://cdn.grofers.com/app/images/products/english-oven.jpg" },
    { name: "Wibs Multigrain Bread", weight: "450 g", price: "₹60", image: "https://cdn.grofers.com/app/images/products/wibs-bread.jpg" },
    { name: "Modern White Bread", weight: "350 g", price: "₹35", image: "https://cdn.grofers.com/app/images/products/modern-white.jpg" },
    { name: "Britannia Milk Bread", weight: "400 g", price: "₹48", image: "https://cdn.grofers.com/app/images/products/britannia-milk-bread.jpg" },
    { name: "Bonn Bread Slice", weight: "400 g", price: "₹38", image: "https://cdn.grofers.com/app/images/products/bonn-bread.jpg" },
    { name: "Harvest Gold Brown Bread", weight: "400 g", price: "₹48", image: "https://cdn.grofers.com/app/images/products/harvest-brown.jpg" },
  ],
  rice: [
    { name: "India Gate Basmati Rice", weight: "1 kg", price: "₹165", image: "https://cdn.grofers.com/app/images/products/india-gate.jpg" },
    { name: "Daawat Rozana Basmati Rice", weight: "1 kg", price: "₹120", image: "https://cdn.grofers.com/app/images/products/daawat.jpg" },
    { name: "Fortune Everyday Basmati Rice", weight: "1 kg", price: "₹95", image: "https://cdn.grofers.com/app/images/products/fortune-rice.jpg" },
    { name: "Kohinoor Super Value Basmati", weight: "1 kg", price: "₹130", image: "https://cdn.grofers.com/app/images/products/kohinoor.jpg" },
    { name: "Lal Qilla Traditional Basmati", weight: "1 kg", price: "₹185", image: "https://cdn.grofers.com/app/images/products/lal-qilla.jpg" },
    { name: "24 Mantra Organic Sonamasuri", weight: "1 kg", price: "₹110", image: "https://cdn.grofers.com/app/images/products/24mantra.jpg" },
    { name: "Tata Sampann Unpolished Rice", weight: "1 kg", price: "₹78", image: "https://cdn.grofers.com/app/images/products/tata-rice.jpg" },
    { name: "India Gate Feast Rozzana", weight: "1 kg", price: "₹105", image: "https://cdn.grofers.com/app/images/products/india-gate-feast.jpg" },
    { name: "Daawat Brown Basmati Rice", weight: "1 kg", price: "₹145", image: "https://cdn.grofers.com/app/images/products/daawat-brown.jpg" },
    { name: "Fortune Biryani Special Rice", weight: "1 kg", price: "₹140", image: "https://cdn.grofers.com/app/images/products/fortune-biryani.jpg" },
  ],
  eggs: [
    { name: "Fresho Farm Eggs", weight: "6 pcs", price: "₹54", image: "https://cdn.grofers.com/app/images/products/fresho-eggs.jpg" },
    { name: "Nandini Brown Eggs", weight: "6 pcs", price: "₹72", image: "https://cdn.grofers.com/app/images/products/nandini-eggs.jpg" },
    { name: "Fresho White Eggs", weight: "12 pcs", price: "₹96", image: "https://cdn.grofers.com/app/images/products/fresho-white-eggs.jpg" },
    { name: "Keggs Farm Fresh Eggs", weight: "6 pcs", price: "₹60", image: "https://cdn.grofers.com/app/images/products/keggs.jpg" },
    { name: "Happy Hens Free Range Eggs", weight: "6 pcs", price: "₹120", image: "https://cdn.grofers.com/app/images/products/happy-hens.jpg" },
    { name: "ITC B Natural Eggs", weight: "10 pcs", price: "₹85", image: "https://cdn.grofers.com/app/images/products/itc-eggs.jpg" },
    { name: "Suguna Brown Eggs", weight: "6 pcs", price: "₹65", image: "https://cdn.grofers.com/app/images/products/suguna-eggs.jpg" },
    { name: "Fresho Omega 3 Eggs", weight: "6 pcs", price: "₹95", image: "https://cdn.grofers.com/app/images/products/omega-eggs.jpg" },
    { name: "Country Delight Eggs", weight: "6 pcs", price: "₹78", image: "https://cdn.grofers.com/app/images/products/country-delight.jpg" },
    { name: "Protein Eggs Premium", weight: "12 pcs", price: "₹130", image: "https://cdn.grofers.com/app/images/products/protein-eggs.jpg" },
  ],
  sugar: [
    { name: "India Gate Sugar", weight: "1 kg", price: "₹48", image: "https://cdn.grofers.com/app/images/products/india-gate-sugar.jpg" },
    { name: "Uttam Sugar", weight: "1 kg", price: "₹45", image: "https://cdn.grofers.com/app/images/products/uttam-sugar.jpg" },
    { name: "Trust Classic Sugar", weight: "1 kg", price: "₹46", image: "https://cdn.grofers.com/app/images/products/trust-sugar.jpg" },
    { name: "24 Mantra Organic Sugar", weight: "500 g", price: "₹55", image: "https://cdn.grofers.com/app/images/products/24mantra-sugar.jpg" },
    { name: "Dhampure Sulphurless Sugar", weight: "1 kg", price: "₹58", image: "https://cdn.grofers.com/app/images/products/dhampure.jpg" },
    { name: "Madhur Pure Sugar", weight: "1 kg", price: "₹48", image: "https://cdn.grofers.com/app/images/products/madhur-sugar.jpg" },
    { name: "Tata Pure Sugar", weight: "1 kg", price: "₹52", image: "https://cdn.grofers.com/app/images/products/tata-sugar.jpg" },
    { name: "BB Royal Sugar", weight: "1 kg", price: "₹44", image: "https://cdn.grofers.com/app/images/products/bb-sugar.jpg" },
    { name: "Reliance Fresh Sugar", weight: "1 kg", price: "₹45", image: "https://cdn.grofers.com/app/images/products/reliance-sugar.jpg" },
    { name: "Organic India Jaggery Powder", weight: "500 g", price: "₹85", image: "https://cdn.grofers.com/app/images/products/organic-jaggery.jpg" },
  ],
  oil: [
    { name: "Fortune Sunflower Oil", weight: "1 L", price: "₹145", image: "https://cdn.grofers.com/app/images/products/fortune-sunflower.jpg" },
    { name: "Saffola Gold Oil", weight: "1 L", price: "₹195", image: "https://cdn.grofers.com/app/images/products/saffola-gold.jpg" },
    { name: "Nature Fresh Kachi Ghani Mustard", weight: "1 L", price: "₹175", image: "https://cdn.grofers.com/app/images/products/nature-fresh.jpg" },
    { name: "Sundrop Heart Sunflower Oil", weight: "1 L", price: "₹155", image: "https://cdn.grofers.com/app/images/products/sundrop.jpg" },
    { name: "Fortune Rice Bran Oil", weight: "1 L", price: "₹170", image: "https://cdn.grofers.com/app/images/products/fortune-ricebran.jpg" },
    { name: "Dhara Mustard Oil", weight: "1 L", price: "₹165", image: "https://cdn.grofers.com/app/images/products/dhara.jpg" },
    { name: "Figaro Olive Oil", weight: "500 ml", price: "₹380", image: "https://cdn.grofers.com/app/images/products/figaro.jpg" },
    { name: "Patanjali Mustard Oil", weight: "1 L", price: "₹160", image: "https://cdn.grofers.com/app/images/products/patanjali-oil.jpg" },
    { name: "Saffola Active Blended Oil", weight: "1 L", price: "₹185", image: "https://cdn.grofers.com/app/images/products/saffola-active.jpg" },
    { name: "Freedom Refined Sunflower Oil", weight: "1 L", price: "₹138", image: "https://cdn.grofers.com/app/images/products/freedom-oil.jpg" },
  ],
  atta: [
    { name: "Aashirvaad Whole Wheat Atta", weight: "5 kg", price: "₹295", image: "https://cdn.grofers.com/app/images/products/aashirvaad.jpg" },
    { name: "Fortune Chakki Fresh Atta", weight: "5 kg", price: "₹275", image: "https://cdn.grofers.com/app/images/products/fortune-atta.jpg" },
    { name: "Pillsbury Chakki Atta", weight: "5 kg", price: "₹265", image: "https://cdn.grofers.com/app/images/products/pillsbury.jpg" },
    { name: "Shakti Bhog Atta", weight: "5 kg", price: "₹255", image: "https://cdn.grofers.com/app/images/products/shakti-bhog.jpg" },
    { name: "Nature Fresh Sampoorna Atta", weight: "5 kg", price: "₹270", image: "https://cdn.grofers.com/app/images/products/nature-fresh-atta.jpg" },
    { name: "Patanjali Whole Wheat Atta", weight: "5 kg", price: "₹245", image: "https://cdn.grofers.com/app/images/products/patanjali-atta.jpg" },
    { name: "Aashirvaad Select Sharbati", weight: "5 kg", price: "₹365", image: "https://cdn.grofers.com/app/images/products/aashirvaad-select.jpg" },
    { name: "Rajdhani Besan", weight: "1 kg", price: "₹120", image: "https://cdn.grofers.com/app/images/products/rajdhani-besan.jpg" },
    { name: "Sujata Gold Atta", weight: "5 kg", price: "₹280", image: "https://cdn.grofers.com/app/images/products/sujata.jpg" },
    { name: "Annapurna Farm Fresh Atta", weight: "5 kg", price: "₹258", image: "https://cdn.grofers.com/app/images/products/annapurna.jpg" },
  ],
  dal: [
    { name: "Tata Sampann Toor Dal", weight: "1 kg", price: "₹165", image: "https://cdn.grofers.com/app/images/products/tata-toor.jpg" },
    { name: "Fortune Arhar Dal", weight: "1 kg", price: "₹155", image: "https://cdn.grofers.com/app/images/products/fortune-arhar.jpg" },
    { name: "24 Mantra Organic Moong Dal", weight: "500 g", price: "₹125", image: "https://cdn.grofers.com/app/images/products/24mantra-moong.jpg" },
    { name: "BB Royal Chana Dal", weight: "1 kg", price: "₹118", image: "https://cdn.grofers.com/app/images/products/bb-chana.jpg" },
    { name: "Tata Sampann Masoor Dal", weight: "1 kg", price: "₹135", image: "https://cdn.grofers.com/app/images/products/tata-masoor.jpg" },
    { name: "Vedaka Premium Urad Dal", weight: "1 kg", price: "₹185", image: "https://cdn.grofers.com/app/images/products/vedaka-urad.jpg" },
    { name: "Patanjali Toor Dal", weight: "1 kg", price: "₹145", image: "https://cdn.grofers.com/app/images/products/patanjali-toor.jpg" },
    { name: "Organic Tattva Yellow Moong", weight: "500 g", price: "₹95", image: "https://cdn.grofers.com/app/images/products/organic-moong.jpg" },
    { name: "Fortune Moong Dal", weight: "1 kg", price: "₹165", image: "https://cdn.grofers.com/app/images/products/fortune-moong.jpg" },
    { name: "BB Popular Arhar Dal", weight: "1 kg", price: "₹140", image: "https://cdn.grofers.com/app/images/products/bb-arhar.jpg" },
  ],
  vegetables: [
    { name: "Fresh Tomato", weight: "500 g", price: "₹25", image: "https://cdn.grofers.com/app/images/products/tomato.jpg" },
    { name: "Onion", weight: "1 kg", price: "₹40", image: "https://cdn.grofers.com/app/images/products/onion.jpg" },
    { name: "Potato", weight: "1 kg", price: "₹35", image: "https://cdn.grofers.com/app/images/products/potato.jpg" },
    { name: "Green Capsicum", weight: "250 g", price: "₹32", image: "https://cdn.grofers.com/app/images/products/capsicum.jpg" },
    { name: "Carrot", weight: "500 g", price: "₹35", image: "https://cdn.grofers.com/app/images/products/carrot.jpg" },
    { name: "Cucumber", weight: "500 g", price: "₹28", image: "https://cdn.grofers.com/app/images/products/cucumber.jpg" },
    { name: "Lady Finger (Bhindi)", weight: "250 g", price: "₹30", image: "https://cdn.grofers.com/app/images/products/bhindi.jpg" },
    { name: "Cauliflower", weight: "1 pc", price: "₹45", image: "https://cdn.grofers.com/app/images/products/cauliflower.jpg" },
    { name: "Spinach (Palak)", weight: "250 g", price: "₹22", image: "https://cdn.grofers.com/app/images/products/palak.jpg" },
    { name: "Brinjal (Baingan)", weight: "500 g", price: "₹35", image: "https://cdn.grofers.com/app/images/products/brinjal.jpg" },
  ],
  snacks: [
    { name: "Lay's Classic Salted", weight: "90 g", price: "₹30", image: "https://cdn.grofers.com/app/images/products/lays.jpg" },
    { name: "Kurkure Masala Munch", weight: "100 g", price: "₹20", image: "https://cdn.grofers.com/app/images/products/kurkure.jpg" },
    { name: "Haldiram's Aloo Bhujia", weight: "200 g", price: "₹55", image: "https://cdn.grofers.com/app/images/products/haldirams-bhujia.jpg" },
    { name: "Bingo Mad Angles", weight: "90 g", price: "₹20", image: "https://cdn.grofers.com/app/images/products/bingo.jpg" },
    { name: "Parle Monaco Biscuits", weight: "200 g", price: "₹35", image: "https://cdn.grofers.com/app/images/products/monaco.jpg" },
    { name: "Hide & Seek Cookies", weight: "200 g", price: "₹45", image: "https://cdn.grofers.com/app/images/products/hide-seek.jpg" },
    { name: "Britannia Good Day", weight: "200 g", price: "₹40", image: "https://cdn.grofers.com/app/images/products/good-day.jpg" },
    { name: "Bikaji Sev Bhujia", weight: "200 g", price: "₹50", image: "https://cdn.grofers.com/app/images/products/bikaji.jpg" },
    { name: "Pringles Original", weight: "110 g", price: "₹99", image: "https://cdn.grofers.com/app/images/products/pringles.jpg" },
    { name: "Oreo Vanilla Cream", weight: "150 g", price: "₹35", image: "https://cdn.grofers.com/app/images/products/oreo.jpg" },
  ],
};

// Function to get mock products with slight price variation for different locations
function getMockProducts(product, location, source) {
  const searchTerm = product.toLowerCase();
  let products = [];

  // Find matching category
  for (const [category, items] of Object.entries(mockGroceryProducts)) {
    if (searchTerm.includes(category) || category.includes(searchTerm)) {
      products = items;
      break;
    }
  }

  // If no exact match, search in all products
  if (products.length === 0) {
    for (const items of Object.values(mockGroceryProducts)) {
      for (const item of items) {
        if (item.name.toLowerCase().includes(searchTerm)) {
          products.push(item);
        }
      }
    }
  }

  // Default to random category if still no match
  if (products.length === 0) {
    const categories = Object.keys(mockGroceryProducts);
    const randomCategory = categories[Math.floor(Math.random() * categories.length)];
    products = mockGroceryProducts[randomCategory];
  }

  // Add source and slight price variation based on location
  const isVirar = location?.toLowerCase().includes("virar") || location?.toLowerCase().includes("vasai");
  const priceMultiplier = isVirar ? 1.02 : 1.0; // Slightly higher prices in outskirts

  return products.slice(0, 10).map(p => ({
    ...p,
    price: isVirar ? `₹${Math.round(parseFloat(p.price.replace("₹", "")) * priceMultiplier)}` : p.price,
    source: source,
    availability: Math.random() > 0.1 ? "In Stock" : "Out of Stock"
  }));
}

// ----------------------
// Real API - Zepto scraper function
async function scrapeZeptoReal(product, latitude = 19.0760, longitude = 72.8777) {
  try {
    // Try search endpoint
    const searchUrl = `https://api.zeptonow.com/api/v3/search?query=${encodeURIComponent(product)}&latitude=${latitude}&longitude=${longitude}`;

    const searchResponse = await fetch(searchUrl, {
      method: "GET",
      headers: {
        ...getCommonHeaders(),
        "Origin": "https://www.zeptonow.com",
        "Referer": "https://www.zeptonow.com/",
      },
    });

    if (!searchResponse.ok) {
      throw new Error(`Zepto search failed: ${searchResponse.status}`);
    }

    const searchData = await searchResponse.json();
    return parseZeptoProducts(searchData);
  } catch (error) {
    console.error("Zepto scraping error:", error.message);
    return { error: error.message, products: [] };
  }
}

function parseZeptoProducts(data) {
  const products = [];
  const items = data?.products || data?.items || data?.data?.products || data?.data?.items || [];

  for (const item of items.slice(0, 10)) {
    products.push({
      name: item.name || item.productName || item.title || "No name",
      price: item.mrp ? `₹${item.mrp}` : item.price ? `₹${item.price}` : item.sellingPrice ? `₹${item.sellingPrice}` : "No price",
      image: item.image || item.imageUrl || item.images?.[0] || "",
      weight: item.quantity || item.weight || item.unitQuantity || "",
      source: "zepto"
    });
  }

  return products;
}

// ----------------------
// Real API - Blinkit scraper function
async function scrapeBlinkitReal(location, product, latitude = 19.0760, longitude = 72.8777) {
  try {
    const searchUrl = `https://blinkit.com/v6/search/products?q=${encodeURIComponent(product)}&size=10`;

    const response = await fetch(searchUrl, {
      method: "GET",
      headers: {
        ...getCommonHeaders(),
        "Origin": "https://blinkit.com",
        "Referer": "https://blinkit.com/",
        "lat": latitude.toString(),
        "lon": longitude.toString(),
      },
    });

    if (!response.ok) {
      throw new Error(`Blinkit search failed: ${response.status}`);
    }

    const data = await response.json();
    return parseBlinkitProducts(data);
  } catch (error) {
    console.error("Blinkit scraping error:", error.message);
    return { error: error.message, products: [] };
  }
}

function parseBlinkitProducts(data) {
  const products = [];
  const items = data?.products || data?.items || data?.data?.products || data?.snippets || [];

  for (const item of items.slice(0, 10)) {
    products.push({
      name: item.name || item.product_name || item.title || "No name",
      price: item.price ? `₹${item.price}` : item.mrp ? `₹${item.mrp}` : item.offer_price ? `₹${item.offer_price}` : "No price",
      image: item.image_url || item.image || item.thumbnail || "",
      weight: item.unit || item.weight || item.quantity || "",
      source: "blinkit"
    });
  }

  return products;
}

// Location coordinates mapping for Indian cities
const locationCoordinates = {
  // Mumbai areas
  "mumbai": { lat: 19.0760, lng: 72.8777 },
  "south mumbai": { lat: 18.9220, lng: 72.8347 },
  "andheri": { lat: 19.1136, lng: 72.8697 },
  "andheri west": { lat: 19.1360, lng: 72.8296 },
  "andheri east": { lat: 19.1136, lng: 72.8697 },
  "bandra": { lat: 19.0596, lng: 72.8295 },
  "bandra west": { lat: 19.0544, lng: 72.8255 },
  "dadar": { lat: 19.0176, lng: 72.8426 },
  "borivali": { lat: 19.2307, lng: 72.8567 },
  "borivali west": { lat: 19.2360, lng: 72.8441 },
  "thane": { lat: 19.2183, lng: 72.9781 },
  "powai": { lat: 19.1176, lng: 72.9060 },
  "malad": { lat: 19.1873, lng: 72.8486 },
  "malad west": { lat: 19.1873, lng: 72.8399 },
  "goregaon": { lat: 19.1663, lng: 72.8526 },
  "kandivali": { lat: 19.2047, lng: 72.8525 },
  "juhu": { lat: 19.1075, lng: 72.8263 },
  "worli": { lat: 19.0176, lng: 72.8153 },
  "lower parel": { lat: 19.0048, lng: 72.8305 },
  "chembur": { lat: 19.0622, lng: 72.8977 },
  "mulund": { lat: 19.1726, lng: 72.9563 },
  "ghatkopar": { lat: 19.0863, lng: 72.9081 },

  // Virar/Vasai areas
  "virar": { lat: 19.4559, lng: 72.8111 },
  "virar west": { lat: 19.4559, lng: 72.7950 },
  "virar east": { lat: 19.4559, lng: 72.8200 },
  "nalasopara": { lat: 19.4181, lng: 72.8144 },
  "nalasopara west": { lat: 19.4181, lng: 72.8000 },
  "nalasopara east": { lat: 19.4181, lng: 72.8300 },
  "vasai": { lat: 19.3919, lng: 72.8397 },
  "vasai west": { lat: 19.3955, lng: 72.8128 },
  "vasai east": { lat: 19.3919, lng: 72.8600 },

  // Delhi NCR
  "delhi": { lat: 28.6139, lng: 77.2090 },
  "new delhi": { lat: 28.6139, lng: 77.2090 },
  "noida": { lat: 28.5355, lng: 77.3910 },
  "gurgaon": { lat: 28.4595, lng: 77.0266 },
  "gurugram": { lat: 28.4595, lng: 77.0266 },
  "faridabad": { lat: 28.4089, lng: 77.3178 },
  "ghaziabad": { lat: 28.6692, lng: 77.4538 },

  // Bangalore
  "bangalore": { lat: 12.9716, lng: 77.5946 },
  "bengaluru": { lat: 12.9716, lng: 77.5946 },
  "koramangala": { lat: 12.9352, lng: 77.6245 },
  "indiranagar": { lat: 12.9784, lng: 77.6408 },
  "whitefield": { lat: 12.9698, lng: 77.7500 },

  // Other cities
  "pune": { lat: 18.5204, lng: 73.8567 },
  "hyderabad": { lat: 17.3850, lng: 78.4867 },
  "chennai": { lat: 13.0827, lng: 80.2707 },
  "kolkata": { lat: 22.5726, lng: 88.3639 },
};

function getCoordinatesForLocation(location) {
  if (!location) return { lat: 19.0760, lng: 72.8777 }; // Default Mumbai

  const normalized = location.toLowerCase().trim();

  // Direct match
  if (locationCoordinates[normalized]) {
    return locationCoordinates[normalized];
  }

  // Partial match
  for (const [key, coords] of Object.entries(locationCoordinates)) {
    if (normalized.includes(key) || key.includes(normalized)) {
      return coords;
    }
  }

  // Default to Mumbai
  console.log(`Location "${location}" not found, defaulting to Mumbai`);
  return { lat: 19.0760, lng: 72.8777 };
}

// ----------------------
// Main scraper functions that switch between real and mock
async function scrapeZepto(product, latitude, longitude, location) {
  if (USE_REAL_API) {
    return await scrapeZeptoReal(product, latitude, longitude);
  }
  return getMockProducts(product, location, "zepto");
}

async function scrapeBlinkit(location, product, latitude, longitude) {
  if (USE_REAL_API) {
    return await scrapeBlinkitReal(location, product, latitude, longitude);
  }
  return getMockProducts(product, location, "blinkit");
}

// ----------------------
// Merged endpoint: /search-all
app.post("/search-all", async (req, res) => {
  let { location, product, latitude, longitude } = req.body;

  if (!product) {
    return res.status(400).json({ error: "Product is required" });
  }

  // Get coordinates from location if lat/lng not provided
  let coords = { lat: latitude, lng: longitude };
  if (!latitude || !longitude) {
    coords = getCoordinatesForLocation(location || "mumbai");
  }

  console.log(`Searching for "${product}" at location: ${location || 'default'} (${coords.lat}, ${coords.lng}) [Mode: ${USE_REAL_API ? 'REAL API' : 'MOCK DATA'}]`);

  try {
    const [zeptoResults, blinkitResults] = await Promise.all([
      scrapeZepto(product, coords.lat, coords.lng, location),
      scrapeBlinkit(location, product, coords.lat, coords.lng)
    ]);

    res.json({
      zepto: Array.isArray(zeptoResults) ? zeptoResults : zeptoResults.products || [],
      blinkit: Array.isArray(blinkitResults) ? blinkitResults : blinkitResults.products || [],
      location: {
        name: location || "Mumbai",
        coordinates: coords
      },
      mode: USE_REAL_API ? "live" : "demo"
    });
  } catch (error) {
    console.error("Error in merged scraping:", error);
    res.status(500).json({ error: "Failed to scrape data", details: error.toString() });
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    mode: USE_REAL_API ? "live" : "demo"
  });
});

// Test endpoint to check coordinates resolution
app.get("/test-location/:location", (req, res) => {
  const location = req.params.location;
  const coords = getCoordinatesForLocation(location);
  res.json({ location, coordinates: coords });
});

// List available locations
app.get("/locations", (req, res) => {
  res.json({
    locations: Object.keys(locationCoordinates).sort(),
    count: Object.keys(locationCoordinates).length
  });
});

// List available product categories (for mock mode)
app.get("/categories", (req, res) => {
  res.json({
    categories: Object.keys(mockGroceryProducts),
    mode: USE_REAL_API ? "live" : "demo"
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log(`Mode: ${USE_REAL_API ? 'REAL API (requires network)' : 'MOCK DATA (for demo/testing)'}`);
  console.log(`To enable real API: USE_REAL_API=true node server.js`);
});

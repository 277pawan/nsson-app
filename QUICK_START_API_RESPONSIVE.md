# Quick Start: API-Responsive Products

## 🚀 For Developers

### Setup (First Time)

1. **Start Backend**
```bash
cd Garage_admin_backend-master/backend
npm install
npm run dev
```
Backend runs on `http://localhost:8080/api`

2. **Configure Android Emulator**
The app uses `http://10.0.2.2:8080/api` for Android (built-in alias for host machine)

3. **Run App**
```bash
cd moto_crafter_app
flutter run
```

### What Happens on Startup

1. App launches
2. `_AuthGate` initializes ProductProvider
3. ProductProvider.loadAll() sends 4 API requests:
   - GET /api/products
   - GET /api/brands
   - GET /api/categories
   - GET /api/banners?live=true
4. UI displays fetched data
5. User can pull-to-refresh to get latest data

### Verify API Integration

✅ Look for these in debug console:
```
flutter: [ApiService][GET] http://10.0.2.2:8080/api/products
flutter: [ApiService][GET] http://10.0.2.2:8080/api/brands
flutter: [ApiService][GET] http://10.0.2.2:8080/api/categories
flutter: [ApiService][GET] http://10.0.2.2:8080/api/banners?live=true
```

✅ Home screen should show:
- Real products (not "Headlight Visor", "Chain Sprocket" dummy names)
- Actual prices from backend
- Real brand logos
- Promotional banners

### Change API Base URL

Edit `lib/core/services/api_service.dart`:

```dart
static String get baseUrl {
  // For physical device on same Wi-Fi:
  if (Platform.isAndroid) {
    return 'http://192.168.1.100:8080/api'; // Replace with your machine IP
  }
  // OR use environment variable:
  // flutter run --dart-define=API_BASE_URL=https://your-backend.com/api
}
```

---

## 👨‍💼 For Product Managers / Admin

### Add New Products (Zero Code)

1. Open Garage Admin Dashboard
2. Add product with:
   - Name, Part Number
   - Brand, Category
   - Price, Stock, Discount
   - Image URL
   - Description
3. Save

### Product Appears Automatically

Options:
- **Immediate**: User pulls-to-refresh on home screen
- **On Next Startup**: App fetches latest products
- **Real-time** (Future): WebSocket updates (not implemented yet)

### No Need to:
❌ Modify code  
❌ Rebuild app  
❌ Update DummyData  
❌ Redeploy APK  

---

## 🔧 For Backend Developers

### API Endpoints Used

```
GET /api/products              # All products (with optional category/brand filters)
GET /api/brands                # All brands
GET /api/categories            # All categories
GET /api/banners?live=true     # Active promotional banners
GET /api/products/:id          # Single product detail
```

### Expected Response Format

**Products Endpoint**: `GET /api/products`
```json
{
  "success": true,
  "products": [
    {
      "_id": "mongo_id",
      "name": "Product Name",
      "partNumber": "ABC-123",
      "brand": "Brand Name",
      "category": "Category Name",
      "price": 500,
      "discount": 10,
      "stock": 150,
      "image": "https://example.com/image.jpg",
      "images": ["https://...", "https://..."],
      "description": "Product description",
      "warrantyMonths": 12
    }
  ],
  "total": 1
}
```

**Brands Endpoint**: `GET /api/brands`
```json
{
  "success": true,
  "brands": [
    {
      "_id": "brand_id",
      "name": "Hero",
      "logo": "https://example.com/hero-logo.png"
    }
  ],
  "total": 1
}
```

**Categories Endpoint**: `GET /api/categories`
```json
{
  "categories": [
    {
      "_id": "cat_id",
      "name": "Braking System",
      "description": "..."
    }
  ],
  "total": 1
}
```

**Banners Endpoint**: `GET /api/banners?live=true`
```json
{
  "success": true,
  "data": [
    {
      "_id": "banner_id",
      "title": "Banner Title",
      "image": "https://example.com/banner.jpg",
      "isLive": true
    }
  ]
}
```

---

## 🐛 Troubleshooting

### Issue: Blank screen / No products
**Cause**: Backend not running  
**Fix**: 
```bash
npm run dev  # in backend folder
```

### Issue: Products from dummy data instead of API
**Cause**: API request failed  
**Check**:
```
1. Backend running? npm run dev
2. API URL correct? Check ApiService.baseUrl
3. Network connectivity? Can you curl the API?
4. Product data exists? Check MongoDB
```

### Issue: Old products still showing
**Cause**: App has cached data  
**Fix**:
1. Pull-to-refresh on HomeScreen
2. Or kill app and restart
3. Or use `flutter run --release` to clear cache

### Issue: "Add to cart" fails but products show
**Cause**: Likely auth/cart API issue  
**Check**: User is logged in  

### Issue: Product images not loading
**Cause**: Image URL might be invalid  
**Fix**: Verify image URLs return 200 status code  

### Issue: New products don't show immediately
**Expected behavior**: App caches data for 1 app lifecycle  
**Fix**: Pull-to-refresh or restart app  

---

## 📚 Key Files

| File | Purpose |
|------|---------|
| `lib/providers/product_provider.dart` | State management, API calls, data merging |
| `lib/data/repositories/product_repository.dart` | Clean API layer (optional) |
| `lib/core/services/api_service.dart` | HTTP client, auth headers |
| `lib/data/models.dart` | Product, Brand, Category data models |
| `lib/screens/home/home_screen.dart` | Entry point, triggers loadAll() |
| `API_RESPONSIVE_ARCHITECTURE.md` | Complete technical documentation |

---

## ✨ Architecture Benefits

| Feature | Benefit |
|---------|---------|
| **API-First** | Real data always shown (when available) |
| **Offline Support** | Falls back to DummyData if API down |
| **Dynamic Updates** | New products appear without code changes |
| **Scalable** | Easy to add new endpoints |
| **Testable** | API layer can be mocked |
| **Maintainable** | Clear separation of concerns |

---

## 🎯 Next Steps

1. ✅ Backend running? Start it: `npm run dev`
2. ✅ App running? Launch: `flutter run`
3. ✅ See real products? Check home screen
4. ✅ Pull-to-refresh? Should get latest data
5. ✅ Add product in admin? Appears after refresh

**Done!** Your app is now API-responsive! 🎉


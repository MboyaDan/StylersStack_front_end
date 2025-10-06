# StylerStack – Frontend (Flutter)

This app provides a seamless shopping experience with real-time payments, authentication, and push notifications.

---

## ✨ Features

### **Authentication**
- Firebase Authentication (Email/Password, Google)
- Secure user sessions across app restarts

### **Payments**
- Mpesa Daraja API integration
- Cash on Delivery
- Real-time payment confirmation via Firebase Cloud Messaging (FCM) (no polling)

### **State Management**
- Provider for app-wide state  
(Currently exploring Riverpod for advanced state patterns)

### **UI/UX**
- Built with Material UI principles for consistency  
- Clean, responsive layouts  

### **E-commerce Features**
- Product browsing with categories  
- Cart & Favorites management  
- Address management  
- Checkout & order history  
- Reels section to scroll across products (discounted and flash sale)  

### **Notifications**
- Push notifications (payment status, order updates) via FCM  

### **CI/CD**
- Codemagic for automated builds & debugging  

---

## 🛠️ Tech Stack
- **Flutter** – Mobile app framework  
- **Hive & SharedPreferences** – App cache  
- **Provider** – State management  
- **Firebase Auth** – User authentication & role-based access  
- **Firebase Cloud Messaging (FCM)** – Real-time payment & order notifications  
- **Dio / HTTP** – API client (connects to FastAPI backend)  
- **Codemagic** – Build automation and debugging  
- **Material UI Design** – Consistent and modern look & feel  
- **Dependency Injection**  

✅ Clean coding architecture **MVVM (Model–View–ViewModel)**  

---

## 🔑 Environment Setup
The app requires Firebase setup.  

1. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).  
2. Update the `.env` or constants file with your backend URL:  
   ```dart
   const String baseUrl = "https://your-backend-url.onrender.com";
screenshots
## 📸 Screenshots (Admin Dashboard)

### Dashboard
![Dashboard Screenshot](https://github.com/MboyaDan/StylersStack_back_end/blob/main/docs/admin_dashbord.png)

### Orders
![Orders Screen](https://github.com/MboyaDan/StylersStack_back_end/blob/main/docs/order_screen.png)

### Add New Product
![Add Product Screen](https://github.com/MboyaDan/StylersStack_back_end/blob/main/docs/add_new_product_screen.png)

### Payments
![Payment Screen](https://github.com/MboyaDan/StylersStack_back_end/blob/main/docs/payment_screen.png)

### Products
![Product Screen](https://github.com/MboyaDan/StylersStack_back_end/blob/main/docs/product_screen.png)

## 📱 Screenshots

### Main App Screens
<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/homepage.png" alt="Home" width="250"/></td>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/catscreen.png" alt="Categories" width="250"/></td>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/flashsale.png" alt="Flash Sale" width="250"/></td>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/checkoutscreen.png" alt="Checkout" width="250"/></td>
  </tr>
  <tr>
    <td align="center">HomeScreen</td>
    <td align="center">Cartscreen</td>
    <td align="center">Flash Sale</td>
    <td align="center">Checkout</td>
  </tr>

  <tr>
    <td><img src="https://github.com/MboyaDan/StylersStack_front_end/blob/main/docs/paymentprogress.png" alt="PaymentProgress" width="250"/></td>
    <td><img src="https://github.com/MboyaDan/StylersStack_front_end/blob/main/docs/login_screen.png" alt="LoginScreen" width="250"/></td>
    <td><img src="https://github.com/MboyaDan/StylersStack_front_end/blob/main/docs/product_screen.png" alt="ProductScreen" width="250"/></td>
    <td><img src="https://github.com/MboyaDan/StylersStack_front_end/blob/main/docs/profile.png" alt="ProfileScreen" width="250"/></td>
  </tr>
  <tr>
    <td align="center">PaymentProgress</td>
    <td align="center">LoginScreen</td>
    <td align="center">ProductScreen</td>   
    <td align="center">ProfileScreen</td>     
  </tr>
</table>

---

### Orders & Payments
<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/orderscreen.png" alt="Orders" width="250"/></td>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/oderdetails.png" alt="Order Details" width="250"/></td>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/payment_screen.png" alt="Payment" width="250"/></td>
    <td><img src="https://raw.githubusercontent.com/MboyaDan/StylersStack_front_end/main/docs/payment_success.png" alt="Success" width="250"/></td>
  </tr>
  <tr>
    <td align="center">Order Screen</td>
    <td align="center">Order Details</td>
    <td align="center">Payment</td>
    <td align="center">Payment Success</td>
  </tr>
</table>



# clone the repo
git clone https://github.com/MboyaDan/StylersStack_front_end
cd StylerStack_front_end

# install dependencies
flutter pub get

# run the app
flutter run

🔗 Related Repositories
- [Backend (FastAPI)](https://github.com/MboyaDan/StylersStack_back_end)

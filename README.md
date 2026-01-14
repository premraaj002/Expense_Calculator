#  Expense Tracker App 

A simple, fast, **personal expense tracking mobile app** built using **Flutter**.  
This app is designed for **offline, local usage only** — no cloud, no login, no ads.

All expense data is stored securely on the device using **Hive (local storage)**.

---

## 🚀 Features

### 📅 Months & Expenses
- View expenses grouped by **Month → Date → Individual Expenses**
- See **total spending per day**
- Edit or delete any expense
- Smooth and lag-free performance

### ➕ Add Expense
- Enter expense amount
- Select one or more categories:
  - Food, Grocery, Amazon, Flipkart, Zepto, Swiggy, BigBasket,
    Zomato, Blinkit, Vegetables, Milk, Snacks, Others
- If **Others** is selected → enter custom expense name
- Optional field to note **what was purchased**
- Date selection (default: today)


### 💾 Local Storage Only
- Uses **Hive** for fast local persistence
- No Firebase
- No internet usage
- No authentication

---

## 🧱 Tech Stack

- **Flutter**
- **Hive** (Local NoSQL database)
- Material UI (no animations)

---

## 📂 Project Structure
```lib/
├── models/
│ └── expense_model.dart
├── services/
│ └── hive_service.dart
├── screens/
│ ├── months_screen.dart
│ ├── month_details_screen.dart
│ ├── day_details_screen.dart
│ └── add_expense_screen.dart
├── notifications/
│ └── notification_service.dart
└── main.dart
```
---

## 📝 Expense Data Model

```dart
Expense {
  String id;
  DateTime date;
  double amount;
  List<String> categories;
  String? otherName;
  String? purchasedItems;
} 
```
---

## App Screenshots

<img src="assets/1.jpg" width="250" />
<img src="assets/2.jpg" width="250" />
<img src="assets/3.jpg" width="250" />

---

#This product is licensed under the MIT License.



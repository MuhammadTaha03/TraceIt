# 🔍 Project: TraceIt

A community-driven lost and found board tailored for campuses or neighborhoods. Users can post lost or found items with photos, descriptions, and location tags. The app facilitates item recovery through a seamless claim system, real-time comments, and status updates. The interface features a clean, minimalist, and flat design aesthetic to keep navigation simple and intuitive for all users.

---

## ✨ Features

### 📝 Post Creation & Management
- Upload photos, add location tags, and write descriptions for lost/found items.
- Filter feed by category (e.g., electronics, clothing), area, or post type (Lost vs. Found).

### 🤝 Claim & Resolve Workflow
- Users can claim an item.
- Original posters can mark items as resolved.

### 💬 Real-time Interactions
- Live status updates and comment threads using Supabase Realtime.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter |
| **Backend & Database** | Supabase (PostgreSQL, Storage, Realtime) |
| **State Management** | Riverpod |

---

## 📁 Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── post.dart
│   ├── profile.dart
│   ├── comment.dart
│   └── claim.dart
├── screens/
│   ├── auth_screen.dart
│   ├── home_feed_screen.dart
│   ├── create_post_screen.dart
│   ├── post_details_screen.dart
│   └── profile_screen.dart
├── services/
│   └── supabase_service.dart
├── providers/
│   └── app_providers.dart
└── widgets/
    ├── post_card.dart
    └── comment_tile.dart
```

---

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/MuhammadTaha03/TraceIt
   cd TraceIt
   ```

2. **Run the app**
   ```bash
   flutter run
   ```
---

## 🎓 CRUD Operations

The application features full implementation of Create, Read, Update, and Delete across various app features.

| Operation | Implementation |
|---|---|
| **Create** | Submit new posts, create claims, and add comments. |
| **Read** | Fetch and display posts on the Home screen and load Post Details. |
| **Update** | Update user profile settings or mark an item's status as resolved. |
| **Delete** | Remove your own posts or delete comments. |

---


## 🙌 Team

| Name | Role |
|---|---|
| Talal Ahmed Tarar | Developer |
| Muhammad Taha | Developer |
| Ibrahim Asghar | Developer |

---

## 📄 License

This project is built for academic purposes as part of a university course project at COMSATS University Islamabad.

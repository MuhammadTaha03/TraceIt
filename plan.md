# Project Blueprint: TraceIt

## Overview
A community-driven lost and found board tailored for campuses or neighborhoods. Users can post lost or found items with photos, descriptions, and location tags. The app facilitates item recovery through a seamless claim system, real-time comments, and status updates.

## Tech Stack
* **Frontend:** Flutter
* **Backend & Database:** Supabase (PostgreSQL, Storage, Realtime)
* **State Management:** Riverpod (Ideal for handling async Supabase streams and futures)

## Core Features
1.  **Post Creation:** Upload photos, add location tags, and write descriptions for lost/found items.
2.  **Claim & Resolve Workflow:** Users can claim an item; original posters can mark items as resolved.
3.  **Search & Filters:** Filter feed by category (e.g., electronics, clothing), area, or post type (Lost vs. Found).
4.  **Real-time Updates:** Live status updates and comment threads using Supabase Realtime.
5.  **CRUD Operations:** Full implementation of Create, Read, Update, and Delete across various app features.

## Database Schema (Supabase)
The app will utilize 4 core tables to cover all CRUD operations:

### 1. `profiles`
* `id` (uuid, primary key, references auth.users)
* `username` (text)
* `avatar_url` (text)
* `created_at` (timestamp)

### 2. `posts`
* `id` (uuid, primary key)
* `user_id` (uuid, foreign key to profiles)
* `type` (text - 'lost' or 'found')
* `title` (text)
* `description` (text)
* `location` (text/postgis point)
* `image_url` (text)
* `category` (text)
* `status` (text - 'open', 'resolved')
* `created_at` (timestamp)

### 3. `comments`
* `id` (uuid, primary key)
* `post_id` (uuid, foreign key to posts)
* `user_id` (uuid, foreign key to profiles)
* `content` (text)
* `created_at` (timestamp)

### 4. `claims`
* `id` (uuid, primary key)
* `post_id` (uuid, foreign key to posts)
* `claimant_id` (uuid, foreign key to profiles)
* `status` (text - 'pending', 'accepted', 'rejected')
* `created_at` (timestamp)

## Screen Flow
1.  **Authentication:** Login / Sign-up screens.
2.  **Home Feed:** The main dashboard showing a list of open lost/found items. Includes filter toggles and search bar.
3.  **Create Post:** A form screen with camera/gallery integration, location picker, and text inputs.
4.  **Post Details:** Detailed view of an item, displaying the photo, map location, comments section, and a "Claim" or "Mark Resolved" button.
5.  **Profile / Dashboard:** Manage your own posts, view items you've claimed, and update user profile settings.

## Implementation Steps
1.  **Supabase Setup:** Create project, set up tables, configure Row Level Security (RLS) policies, and set up Storage buckets for images.
2.  **Flutter Scaffolding:** Initialize the Flutter project, set up Riverpod, route management, and theme.
3.  **Authentication Integration:** Build the login/signup flow linking Flutter to Supabase Auth.
4.  **Feed & Read Operations:** Fetch and display posts on the Home screen.
5.  **Create Post Flow:** Implement camera functionality, image uploading to Supabase Storage, and database insertions.
6.  **Details & Interactions:** Build the Post Details screen, implement real-time comments, and the claiming logic.
7.  **Polish & Testing:** Refine UI/UX, verify state management, and test RLS policies.

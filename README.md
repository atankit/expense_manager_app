# Expense Manager App 
The Expense Manager App is a Flutter-based application that helps users efficiently track and manage their expenses. It combines essential financial features like expense tracking, user preferences, and report generation to provide a seamless and user-friendly experience.

## Key Features
### 1. Expense Management
   + Add Expenses: Record detailed expenses with attributes like description, category, amount, and date.
   + Edit Expenses: Modify existing expense entries effortlessly.
   + Delete Expenses: Remove unnecessary or outdated expense records.
   + Local Database: All expense data is securely stored in an SQLite database, ensuring offline functionality.

### 2. User Preferences
  + Currency Settings: Users can select their preferred currency (e.g., INR, USD, EUR) through a settings interface.
  + Persistent Preferences: Preferred settings are saved using SharedPreferences, making them available across sessions.

### 3. Exception Handling
  + Error Dialogs: Graceful handling of database errors with informative dialogs, ensuring users understand and resolve issues easily
  + Fallback Mechanisms: Robust checks to prevent app crashes during operations like adding or fetching expenses.

### 4. PDF Report Generation
  + Export Reports: Generate detailed, professional PDF reports of expenses within a selected date range.
  + Customizable Date Range: Select a start and end date for focused reporting.
  + Storage Integration: Save reports directly to the Downloads folder for easy access.
  + Permission Handling: Seamlessly request and handle necessary permissions for file storage.

## Technologies Used
 + Flutter Framework: Cross-platform app development.
 + SQLite: Local database for expense storage.
 + SharedPreferences: Persistent storage for user settings.
 + pdf Package: PDF generation for expense reports.
 + Permission Handler: Managing app permissions for file storage.

## Screenshots 
    

/// All app strings — no hardcoded strings in UI widgets
class AppStrings {
  AppStrings._();

  // App
  static const String appName         = 'CustomerPro';

  // Auth
  static const String login           = 'Login';
  static const String logout          = 'Logout';
  static const String email           = 'Email';
  static const String password        = 'Password';
  static const String emailHint       = 'Enter your email';
  static const String passwordHint    = 'Enter your password';
  static const String loginSuccess    = 'Welcome back!';
  static const String invalidEmail    = 'Enter a valid email address';
  static const String requiredField   = 'This field is required';
  static const String invalidPhone    = 'Enter a valid 10-digit phone number';

  // Dashboard
  static const String dashboard       = 'Dashboard';
  static const String totalCustomers  = 'Total Customers';
  static const String activeCustomers = 'Active';
  static const String inactiveCustomers = 'Inactive';
  static const String viewAll         = 'View All Customers';
  static const String addNew          = 'Add Customer';

  // Customer
  static const String customers       = 'Customers';
  static const String addCustomer     = 'Add Customer';
  static const String editCustomer    = 'Edit Customer';
  static const String fullName        = 'Full Name';
  static const String phone           = 'Phone';
  static const String address         = 'Address';
  static const String status          = 'Status';
  static const String active          = 'Active';
  static const String inactive        = 'Inactive';
  static const String save            = 'Save';
  static const String delete          = 'Delete';
  static const String search          = 'Search by name or email...';
  static const String filter          = 'Filter';
  static const String noCustomers     = 'No customers found';
  static const String deleteConfirm   = 'Customer deleted';
  static const String undoLabel       = 'UNDO';
  static const String filterByStatus  = 'Filter by Status';
  static const String all             = 'All';
  static const String pullToRefresh   = 'Pull to refresh';

  // Errors
  static const String networkError    = 'Network error. Please try again.';
  static const String unknownError    = 'Something went wrong.';
  static const String sessionExpired  = 'Session expired. Please login again.';
}

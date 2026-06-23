class ApiRoutes {
  ApiRoutes._();

  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authMe = '/auth/me';
  static const authLogout = '/auth/logout';
  static const forgotPassword = '/auth/forgot-password';
  static String resetPassword(String token) => '/auth/reset-password/$token';
  static const changePassword = '/auth/change-password';
  static const saveFcmToken = '/auth/user/fcm-token';
 

  static const products = '/products';
  static String productById(String id) => '/products/$id';

  static const brands = '/brands';
  static const categories = '/categories';
  static const bannersLive = '/banners?live=true';

  static const cart = '/cart';
  static String cartItem(String productId) => '/cart/$productId';

  static const address = '/address';
  static String addressById(String id) => '/address/$id';
  static String defaultAddress(String id) => '/address/$id/default';

  static const orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  static const notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';

  static const razorpayKey = '/payment/razorpay/key';
  static const razorpayCreateLegacy = '/payment/razorpay/create-order';
  static const razorpayVerify = '/payment/razorpay/verify';
  static const paymentCreateOrder = '/payment/create-order';
  static const paymentVerify = '/payment/verify';

  static const discounts = '/discounts';
}

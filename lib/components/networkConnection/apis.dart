/*............created_by_shirsh shukla...........*/
/*var baseUrl = 'https://alphaxtech.net/ecity/index.php/api/users';

var refreshUrl = 'https://alphaxtech.net/ecity/index.php/token/refresh';
var signinUrl = '$baseUrl/auth/signin';
var forgotpasswordUrl = '$baseUrl/auth/forgotpassword';
var verifyForgotOtpUrl = '$baseUrl/auth/verifyForgotOtp';
var resendForgotOtpUrl = '$baseUrl/auth/resendForgotOtp';
var signupStepOneUrl = '$baseUrl/auth/signupStepOne';
var signupStepTwoUrl = '$baseUrl/auth/signupStepTwo';
var resetPasswordUrl = '$baseUrl/auth/resetPassword';
var socialLoginUrl = '$baseUrl/auth/socialLogin';
var updateProfileUrl = '$baseUrl/setting/updateProfilenew';
var updateNotficationUrl = '$baseUrl/setting/updateNotfication';
var changePasswordUrl = '$baseUrl/setting/changePassword';
var updateProfileAttrUrl = '$baseUrl/setting/updateProfileAttr';
var addActivityUrl = '$baseUrl/store/addActivity';
var storeListUrl = '$baseUrl/store/storeList';
var productlistUrl = '$baseUrl/product/productlist';
var recentallStoresUrl = '$baseUrl/store/recentallStores';
var addtoCartUrl = '$baseUrl/cart/addtoCart';
var productDetailUrl = '$baseUrl/product/productDetail';
var loadCartUrl = '$baseUrl/cart/loadCart/';
var removeItemUrl = '$baseUrl/cart/removeItem';
var addOrderUrl = '$baseUrl/order/addOrder';
var updateFavouriteUrl = '$baseUrl/favourite/updateFavourite';
var profileUrl = '$baseUrl/home/profile';
var orderHistoryUrl = '$baseUrl/home/orderHistory';
var nearbystoresUrl = '$baseUrl/store/nearbystores';
var getDetailBeaconUrl = '$baseUrl/Notification/getDetail/';
var updateNotificationUrl = '$baseUrl/Notification/updateNotification';
var activeBeaconsUrl = '$baseUrl/home/ActiveBeacons';
var applyCoupanUrl = '$baseUrl/cart/applyCoupan';*/

const baseUrl = 'https://alphaxtech.net/ecity/index.php/api/users';
var baseUrlPayment = 'https://alphaxtech.net/ecity/index.php/api';

var refreshUrl = 'https://alphaxtech.net/ecity/index.php/token/refresh';
var signinUrl = '$baseUrl/Auth/signin';
var forgotpasswordUrl = '$baseUrl/Auth/forgotpassword';
var verifyForgotOtpUrl = '$baseUrl/Auth/verifyForgotOtp';
var resendForgotOtpUrl = '$baseUrl/Auth/resendForgotOtp';
var nearByBeacon = "/Nearby/locationNotification";
var signupStepOneUrl = '$baseUrl/Auth/signupStepOne';
var signupStepTwoUrl = '$baseUrl/Auth/signupStepTwo';
var resetPasswordUrl = '$baseUrl/Auth/resetPassword';
var socialLoginUrl = '$baseUrl/Auth/socialLogin';
var updateProfileUrl = '$baseUrl/Setting/updateProfilenew';
var updateNotficationUrl = '$baseUrl/Setting/updateNotfication';
var changePasswordUrl = '$baseUrl/Setting/changePassword';
var updateProfileAttrUrl = '$baseUrl/Setting/updateProfileAttr';
// var addActivityUrl = '$baseUrl/Store/addActivity';
// var storeListUrl = '$baseUrl/Store/storeList';
var productlistUrl = '$baseUrl/Stores/products';
var productListOnTagUrl = '$baseUrl/Stores/pushCamp';
var recentallStoresUrl = '$baseUrl/Stores/home';
var listStoresUrl = '$baseUrl/Stores/homelist'; //list';
var locationStoresUrl = '$baseUrl/Nearby/stores';
var locationNotificationUrl = '$baseUrl/Notification1/locationNotification';
var addtoCartUrl = '$baseUrl/Carts/addtocart';
var productDetailUrl = '$baseUrl/Products/detail/';
var loadCartUrl = '$baseUrl/Carts/mycart';
var removeItemUrl = '$baseUrl/Carts/removeItem/';
var addOrderUrl = '$baseUrl/Orders/confirm';
var stockCheckUrl = '$baseUrl/Orders/stockCheck';
var confirmWithWalletUrl = '$baseUrl/Orders/confirmWithWallet';
var emptyCartUrl = '$baseUrl/Carts/emptyCard';
var checkPaymentUrl = '$baseUrl/Orders/checkPayment';
var saveOrderUrl = '$baseUrl/Orders/saveOrder';
// var updateFavouriteUrl = '$baseUrl/Favourite/updateFavourite';
var favUnfavoriteProductUrl = '$baseUrl/Favourite/favUnfavoriteProduct/';
var favUnfavoriteStoreUrl = '$baseUrl/Favourite/favUnfavoriteStore/';
var favoriteProductUrl = '$baseUrl/Stores/favoriteProduct';
var profileUrl = '$baseUrl/Home/profile';
var orderHistoryUrl = '$baseUrl/Home/orderHistory';
var nearbystoresUrl = '$baseUrl/Nearby';
var getDetailBeaconUrl = '$baseUrl/Notification1/getDetail';
var getCampDetailUrl = '$baseUrl/Notification1/getCampDetail';
var updateNotificationUrl = '$baseUrl/Notification1/updateStatus';
var locationNotificationDetailUrl =
    '$baseUrl/Notification1/locationNotificationDetail';
var logoutUrl =
    'https://alphaxtech.net/ecity/index.php/api/merchant/Auth/logout';
var activeBeaconsUrl = '$baseUrl/Home/ActiveBeacons';
var applyCoupanUrl = '$baseUrl/Cart/applyCoupan';
var bannersUrl = '$baseUrl/Home/banners/';
var cancelOrderUrl = '$baseUrl/Orders/cancelOrder/';
var beaconNotificationsUrl = '$baseUrl/Notification1/beaconNotifications';
var appNotificationsUrl = '$baseUrl/Notification1/appNotifications';
var fetchContactUrl = '$baseUrl/Contact/fetch';
var addEventUrl = '$baseUrl/Event/addEvent';
var editEventUrl = '$baseUrl/Event/editEvent';
var getCategoriesUrl = '$baseUrl/Event/getCategories';
var eventListUrl = '$baseUrl/Event/upcommings';
var fetchPendingEvent = '$baseUrl/Event/fetchPendingEvent';
var eventDetailUrl = '$baseUrl/Event/detail/';
var updateAttendee = '$baseUrl/Event/updateAttende';
var addAttendeeUrl = '$baseUrl/Event/addAttendee';
var GetPrivateLink = '$baseUrl/Event/GetPrivateLink';
var removeAttendeeUrl = '$baseUrl/Event/removeAttendee';
var eventHistoryUrl = '$baseUrl/Event/eventHistory';
var historyUrl = '$baseUrl/Orders/historyNew';
var paymentHistoryUrl = '$baseUrl/Payment/paymentHistory';
var detailUrl = '$baseUrl/Orders/detail/';
var acceptEventUrl = '$baseUrl/Activity/acceptEvent';
var myWallettUrl = '$baseUrl/Payment/myWallet';
/*-----------------------wallet--------------------------*/
var getDropDownDataWalletUrl =
    '$baseUrlPayment/wallet_manage/Wallet/getDropDownData';
var getDropDownDataPayoutUrl =
    '$baseUrlPayment/wallet_manage/Wallet/getDropDownDataPayout';
var getmyWalletsUrl = '$baseUrlPayment/wallet_manage/Wallet/myWallets';
var addWalletDataUrl = '$baseUrlPayment/wallet_manage/Wallet/addWalletData';
var walletIDAvailablityUrl =
    '$baseUrlPayment/wallet_manage/Wallet/wallet_ID_Availablity';
var walletToWalletUrl = '$baseUrlPayment/wallet_manage/Wallet/walletToWallet';
var walletToWalletClanUrl =
    '$baseUrlPayment/wallet_manage/Wallet/walletToWalletByClan';
var changeSecurityPinUrl =
    '$baseUrlPayment/wallet_manage/Wallet/changeSecurityPin';
var requestPayOutUrl = '$baseUrlPayment/wallet_manage/PayOut/requestPayOut';
/*----------------------------------------------------*/

var createClanUrl = '$baseUrl/Clan/createClan';
var myclanListUrl = '$baseUrl/Clan/myclanList';
var groupMessagesUrl = '$baseUrl/Clan/groupMessages/';
var sendMessageUrl = '$baseUrl/Clan/sendMessage';
var editClanUrl = '$baseUrl/Clan/editClan';
var allordersClanUrl = '$baseUrl/Clan/allorders';
var sendInvoiceUrl = '$baseUrl/Clan/sendInvoice';
var claninvoiceListUrl = '$baseUrl/Clan/claninvoiceList';
var claninvoiceDetailtUrl = '$baseUrl/Clan/invoiceDetail/';
var clanAllEventsClanUrl = '$baseUrl/Clan/allEvents';
var clanAllOrdersClanUrl = '$baseUrl/Clan/allorders';
var addDisputeUrl = '$baseUrl/dispute/add_dispute';
var disputeListUrl = '$baseUrl/dispute/disputeList';
var disputeDetailUrl = '$baseUrl/dispute/disputeDetail/';
var sendDisputeMessageUrl = '$baseUrl/dispute/sendDisputeMessage';

const String completeKioskPayment = '$baseUrl/Orders/kioksScanPayment';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_details_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './providers/products.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './providers/cart.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts != null ? previousProducts.items : [],
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders != null ? previousOrders.orders : [],
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop App',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResult) =>
                      authResult.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailsScreen.routeName: (ctx) =>
                auth.isAuth ? ProductDetailsScreen() : AuthScreen(),
            UserProductsScreen.routeName: (ctx) =>
                auth.isAuth ? UserProductsScreen() : AuthScreen(),
            EditProductScreen.routeName: (ctx) =>
                auth.isAuth ? EditProductScreen() : AuthScreen(),
            OrdersScreen.routeName: (ctx) =>
                auth.isAuth ? OrdersScreen() : AuthScreen(),
            CartScreen.routeName: (ctx) =>
                auth.isAuth ? CartScreen() : AuthScreen(),
          },
        ),
      ),
    );
  }
}

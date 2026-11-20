import 'package:shop/constants.dart';

class ProductModel {
  final String image;
  final String brandName;
  final String title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;

  const ProductModel({
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
  });
}

List<ProductModel> demoPopularProducts = [
  ProductModel(
    image: productDemoImg1,
    title: "Virtual Visa Card - \$10",
    brandName: "SAM CARD",
    price: 12.00,
  ),
  ProductModel(
    image: productDemoImg2,
    title: "Virtual Visa Card - \$25",
    brandName: "SAM CARD",
    price: 28.00,
  ),
  ProductModel(
    image: productDemoImg3,
    title: "Instagram Followers - 500",
    brandName: "SOCIAL MEDIA",
    price: 8.00,
    priceAfetDiscount: 6.00,
    dicountpercent: 25,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Instagram Followers - 1,000",
    brandName: "SOCIAL MEDIA",
    price: 15.00,
  ),
  ProductModel(
    image: productDemoImg5,
    title: "PUBG Mobile UC - 660",
    brandName: "GAME TOP-UP",
    price: 9.99,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Free Fire Diamonds - 1,000",
    brandName: "GAME TOP-UP",
    price: 12.50,
  ),
];

List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    image: productDemoImg3,
    title: "Instagram Followers - 500",
    brandName: "SOCIAL MEDIA",
    price: 8.00,
    priceAfetDiscount: 6.00,
    dicountpercent: 25,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "TikTok Followers - 1,000",
    brandName: "SOCIAL MEDIA",
    price: 12.00,
    priceAfetDiscount: 9.00,
    dicountpercent: 25,
  ),
  ProductModel(
    image: productDemoImg5,
    title: "PUBG Mobile UC - 660",
    brandName: "GAME TOP-UP",
    price: 11.99,
    priceAfetDiscount: 9.99,
    dicountpercent: 17,
  ),
];

List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    image: productDemoImg1,
    title: "Virtual Visa Card - \$25",
    brandName: "SAM CARD",
    price: 28.00,
    priceAfetDiscount: 25.00,
    dicountpercent: 11,
  ),
  ProductModel(
    image: productDemoImg2,
    title: "PlayStation Store Gift Card - \$20",
    brandName: "GIFT CARD",
    price: 22.00,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Free Fire Diamonds - 1,000",
    brandName: "GAME TOP-UP",
    price: 12.50,
    priceAfetDiscount: 10.00,
    dicountpercent: 20,
  ),
];

List<ProductModel> kidsProducts = [
  ProductModel(
    image: productDemoImg5,
    title: "PUBG Mobile UC - 325",
    brandName: "GAME TOP-UP",
    price: 5.99,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Free Fire Diamonds - 310",
    brandName: "GAME TOP-UP",
    price: 4.99,
  ),
  ProductModel(
    image: productDemoImg3,
    title: "Xbox Gift Card - \$10",
    brandName: "GIFT CARD",
    price: 11.00,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "PlayStation Store Gift Card - \$20",
    brandName: "GIFT CARD",
    price: 22.00,
    priceAfetDiscount: 20.00,
    dicountpercent: 9,
  ),
  ProductModel(
    image: productDemoImg1,
    title: "Virtual Visa Card - \$10",
    brandName: "SAM CARD",
    price: 12.00,
  ),
  ProductModel(
    image: productDemoImg2,
    title: "TikTok Followers - 500",
    brandName: "SOCIAL MEDIA",
    price: 7.00,
  ),
];

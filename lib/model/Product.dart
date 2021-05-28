class Product {
  final int productId;
  final String productName;
  final String imageUrl;
  final String tags;
  final double donationRecived;
  final int  doationCount;
  final String prodDesc;
  final String prodDesc2;
  final String prodDesc3;
  final String medicationType;

  Product({this.productId,this.productName,this.imageUrl,this.tags,this.donationRecived,this.doationCount,this.prodDesc,this.prodDesc2,this.prodDesc3,this.medicationType});

  factory Product.fromJson(Map<String,dynamic> json) {
    return Product(
        productId: json['productId'],
        productName: json['productName'],
        imageUrl: json['productImageUrl'],
        tags: json['tags'],
        donationRecived: json['donationRecived'],
        doationCount:json['doationCount'],
        prodDesc: json['productDesc'],
        prodDesc2: json['productDesc2'],
        prodDesc3: json['productDesc3'],
        medicationType: json['medicationType']
    );
  }
}

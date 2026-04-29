/*
import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  final String? status;
  final String? message;
  final ProductsItem? data;

  ProductModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : ProductsItem.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProductsItem {
  final int? id;
  final String? productTitle;
  final String? price;
  final String? discountedPrice;
  final String? productDescription;
  final String? stock;
  final String? sku;
  final int? isFeatured;
  final String? status;
  final int? categoryId;
  final int? subCategoryId;
  final int? brandId;
  final int? userId;
  final dynamic ratingsAvgRating;
  final int? ratingsCount;
  final List<GetGalleryImage>? getGalleryImages;
  final GetCategory? getCategory;
  final GetSubCategory? getSubCategory;
  final GetBrand? getBrand;
  final List<ProductColor>? colors;
  final List<dynamic>? sizes;
  final AdditionalInfo? additionalInfo;
  final dynamic additionalInfoRaw;
  final List<dynamic>? variants;
  final GetAdvertInfo? getAdvertInfo;
  final List<dynamic>? ratings;
  final List<dynamic>? stocks;
  final GetProductUser? getProductUser;
  final dynamic slugUrl;
  final Shop? shop;
  final dynamic listingTypeId;
  final dynamic childCategoryId;
  final int? shopId;
  final dynamic discountPercent;
  final dynamic shippingClass;
  final dynamic deliveryTime;
  final dynamic tags;

  final bool? isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;



  ProductsItem({
    this.id,
    this.productTitle,
    this.price,
    this.discountedPrice,
    this.productDescription,
    this.stock,
    this.sku,
    this.isFeatured,
    this.status,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    this.userId,
    this.ratingsAvgRating,
    this.ratingsCount,
    this.getGalleryImages,
    this.getCategory,
    this.getSubCategory,
    this.getBrand,
    this.colors,
    this.sizes,
    this.additionalInfo,
    this.additionalInfoRaw,
    this.variants,
    this.getAdvertInfo,
    this.ratings,
    this.stocks,
    this.getProductUser,
    this.slugUrl,
    this.shop,
    this.listingTypeId,
    this.childCategoryId,
    this.shopId,
    this.discountPercent,
    this.shippingClass,
    this.deliveryTime,
    this.tags,
    this.isFavorite,
    this.createdAt,
    this.updatedAt,
  });

  String? get additionalInfoText {
    if (additionalInfo != null) {
      return additionalInfo!.additionalInfo;
    } else if (additionalInfoRaw != null && additionalInfoRaw is String) {
      return additionalInfoRaw;
    }
    return null;
  }

  factory ProductsItem.fromJson(Map<String, dynamic> json) => ProductsItem(
    id: json["id"],
    productTitle: json["product_title"],
    price: json["price"],
    discountedPrice: json["discounted_price"],
    productDescription: json["product_description"],
    stock: json["stock"],
    sku: json["sku"],
    isFeatured: json["is_featured"],
    status: json["status"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    brandId: json["brand_id"],
    userId: json["user_id"],
    ratingsAvgRating: json["ratings_avg_rating"],
    ratingsCount: json["ratings_count"],
    getGalleryImages: json["get_gallery_images"] == null ? [] : List<GetGalleryImage>.from(json["get_gallery_images"]!.map((x) => GetGalleryImage.fromJson(x))),
    getCategory: json["get_category"] == null ? null : GetCategory.fromJson(json["get_category"]),
    getSubCategory: json["get_sub_category"] == null ? null : GetSubCategory.fromJson(json["get_sub_category"]),
    getBrand: json["get_brand"] == null ? null : GetBrand.fromJson(json["get_brand"]),
    colors: json["colors"] == null ? [] : List<ProductColor>.from(json["colors"]!.map((x) => ProductColor.fromJson(x))),
    sizes: json["sizes"] == null ? [] : List<dynamic>.from(json["sizes"]!.map((x) => x)),
    // additionalInfo: json["additional_info"] == null ? null : AdditionalInfo.fromJson(json["additional_info"]),
    additionalInfo: json["additional_info"] is Map ? AdditionalInfo.fromJson(json["additional_info"]) : null,
    additionalInfoRaw: json["additional_info"] is String ? json["additional_info"] : null,
    variants: json["variants"] == null ? [] : List<dynamic>.from(json["variants"]!.map((x) => x)),
    getAdvertInfo: json["get_advert_info"] == null ? null : GetAdvertInfo.fromJson(json["get_advert_info"]),
    ratings: json["ratings"] == null ? [] : List<dynamic>.from(json["ratings"]!.map((x) => x)),
    stocks: json["stocks"] == null ? [] : List<dynamic>.from(json["stocks"]!.map((x) => x)),
    getProductUser: json["get_product_user"] == null ? null : GetProductUser.fromJson(json["get_product_user"]),
    slugUrl: json["slug_url"],
    shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
    listingTypeId: json["listing_type_id"],
    childCategoryId: json["child_category_id"],
    shopId: json["shop_id"],
    discountPercent: json["discount_percent"],
    shippingClass: json["shipping_class"],
    deliveryTime: json["delivery_time"],
    tags: json["tags"],
    isFavorite: json["is_favorite"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_title": productTitle,
    "price": price,
    "discounted_price": discountedPrice,
    "product_description": productDescription,
    "stock": stock,
    "sku": sku,
    "is_featured": isFeatured,
    "status": status,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "brand_id": brandId,
    "user_id": userId,
    "ratings_avg_rating": ratingsAvgRating,
    "ratings_count": ratingsCount,
    "get_gallery_images": getGalleryImages == null ? [] : List<dynamic>.from(getGalleryImages!.map((x) => x.toJson())),
    "get_category": getCategory?.toJson(),
    "get_sub_category": getSubCategory?.toJson(),
    "get_brand": getBrand?.toJson(),
    "colors": colors == null ? [] : List<dynamic>.from(colors!.map((x) => x.toJson())),
    "sizes": sizes == null ? [] : List<dynamic>.from(sizes!.map((x) => x)),
    // "additional_info": additionalInfo?.toJson(),
    "additional_info": additionalInfo?.toJson() ?? additionalInfoRaw,
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x)),
    "get_advert_info": getAdvertInfo?.toJson(),
    "ratings": ratings == null ? [] : List<dynamic>.from(ratings!.map((x) => x)),
    "stocks": stocks == null ? [] : List<dynamic>.from(stocks!.map((x) => x)),
    "get_product_user": getProductUser?.toJson(),
    "slug_url": slugUrl,
    "listing_type_id": listingTypeId,
    "child_category_id": childCategoryId,
    "shop_id": shopId,
    "discount_percent": discountPercent,
    "shipping_class": shippingClass,
    "delivery_time": deliveryTime,
    "tags": tags,
    "is_favorite": isFavorite,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),

  };
}

class AdditionalInfo {
  final int? id;
  final String? description;
  final String? additionalInfo;
  final String? specification;
  final int? productId;

  AdditionalInfo({
    this.id,
    this.description,
    this.additionalInfo,
    this.specification,
    this.productId,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
    id: json["id"],
    description: json["description"],
    additionalInfo: json["additional_info"],
    specification: json["specification"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "additional_info": additionalInfo,
    "specification": specification,
    "product_id": productId,
  };
}

class ProductColor {
  final int? id;
  final String? color;
  final String? colorName;
  final int? stock;
  final int? productId;
  final List<dynamic>? images;

  ProductColor({
    this.id,
    this.color,
    this.colorName,
    this.stock,
    this.productId,
    this.images,
  });

  factory ProductColor.fromJson(Map<String, dynamic> json) => ProductColor(
    id: json["id"],
    color: json["color"],
    colorName: json["color_name"],
    stock: json["stock"],
    productId: json["product_id"],
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "color": color,
    "color_name": colorName,
    "stock": stock,
    "product_id": productId,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
  };
}

class GetAdvertInfo {
  final int? id;
  final int? productId;

  GetAdvertInfo({
    this.id,
    this.productId,
  });

  factory GetAdvertInfo.fromJson(Map<String, dynamic> json) => GetAdvertInfo(
    id: json["id"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
  };
}

class GetBrand {
  final int? id;
  final String? brandName;

  GetBrand({
    this.id,
    this.brandName,
  });

  factory GetBrand.fromJson(Map<String, dynamic> json) => GetBrand(
    id: json["id"],
    brandName: json["brand_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_name": brandName,
  };
}

class GetCategory {
  final int? id;
  final String? categoryName;

  GetCategory({
    this.id,
    this.categoryName,
  });

  factory GetCategory.fromJson(Map<String, dynamic> json) => GetCategory(
    id: json["id"],
    categoryName: json["category_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_name": categoryName,
  };
}

class GetGalleryImage {
  final int? id;
  final int? productId;
  final String? img;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetGalleryImage({
    this.id,
    this.productId,
    this.img,
    this.createdAt,
    this.updatedAt,
  });

  factory GetGalleryImage.fromJson(Map<String, dynamic> json) => GetGalleryImage(
    id: json["id"],
    productId: json["product_id"],
    img: json["img"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "img": img,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class GetProductUser {
  final int? id;
  final String? name;
  final String? profileImg;
  final String? userType;

  GetProductUser({
    this.id,
    this.name,
    this.profileImg,
    this.userType,
  });

  factory GetProductUser.fromJson(Map<String, dynamic> json) => GetProductUser(
    id: json["id"],
    name: json["name"],
    profileImg: json["profile_img"],
    userType: json["user_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_img": profileImg,
    "user_type": userType,
  };
}

class GetSubCategory {
  final int? id;
  final String? subCategoryName;

  GetSubCategory({
    this.id,
    this.subCategoryName,
  });

  factory GetSubCategory.fromJson(Map<String, dynamic> json) => GetSubCategory(
    id: json["id"],
    subCategoryName: json["sub_category_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sub_category_name": subCategoryName,
  };
}
class Shop {
  final int? id;
  final String? name;
  final String? slug;

  Shop({
    this.id,
    this.name,
    this.slug,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
  };
}*/

import 'dart:convert';

import 'get_message_model.dart';

// ------------------ ProductModel ------------------
ProductModel productModelFromJson(String str) =>
    ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  final String? status;
  final String? message;
  final ProductsItem? data;

  ProductModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : ProductsItem.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

  ProductModel copyWith({
    String? status,
    String? message,
    ProductsItem? data,
  }) {
    return ProductModel(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

// ------------------ ProductsItem ------------------
class ProductsItem {
  final int? id;
  final String? productTitle;
  final String? price;
  final String? discountedPrice;
  final String? productDescription;
  final String? stock;
  final String? sku;
  final int? isFeatured;
  final String? status;
  final int? categoryId;
  final int? subCategoryId;
  final int? brandId;
  final int? userId;
  final dynamic ratingsAvgRating;
  final int? ratingsCount;
  final List<GetGalleryImage>? getGalleryImages;
  final GetCategory? getCategory;
  final GetSubCategory? getSubCategory;
  final GetBrand? getBrand;
  final List<ProductColor>? colors;
  final List<ProductSize>? sizes;
  final AdditionalInfo? additionalInfo;
  final dynamic additionalInfoRaw;
  final List<ProductVariant>? variants;
  final GetAdvertInfo? getAdvertInfo;
  final List<ProductRating>? ratings;
  final List<ProductStock>? stocks;
  final GetProductUser? getProductUser;
  final dynamic slugUrl;
  final Shop? shop;
  final dynamic listingTypeId;
  final dynamic childCategoryId;
  final int? shopId;
  final dynamic discountPercent;
  final dynamic shippingClass;
  final dynamic deliveryTime;
  final dynamic tags;
  final bool? isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductsItem({
    this.id,
    this.productTitle,
    this.price,
    this.discountedPrice,
    this.productDescription,
    this.stock,
    this.sku,
    this.isFeatured,
    this.status,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    this.userId,
    this.ratingsAvgRating,
    this.ratingsCount,
    this.getGalleryImages,
    this.getCategory,
    this.getSubCategory,
    this.getBrand,
    this.colors,
    this.sizes,
    this.additionalInfo,
    this.additionalInfoRaw,
    this.variants,
    this.getAdvertInfo,
    this.ratings,
    this.stocks,
    this.getProductUser,
    this.slugUrl,
    this.shop,
    this.listingTypeId,
    this.childCategoryId,
    this.shopId,
    this.discountPercent,
    this.shippingClass,
    this.deliveryTime,
    this.tags,
    this.isFavorite,
    this.createdAt,
    this.updatedAt,
  });

  String? get additionalInfoText {
    if (additionalInfo != null) {
      return additionalInfo!.additionalInfo;
    } else if (additionalInfoRaw != null && additionalInfoRaw is String) {
      return additionalInfoRaw;
    }
    return null;
  }


  factory ProductsItem.fromJson(Map<String, dynamic> json) => ProductsItem(
    id: json["id"],
    productTitle: json["product_title"],
    price: json["price"],
    discountedPrice: json["discounted_price"],
    productDescription: json["product_description"],
    stock: json["stock"],
    sku: json["sku"],
    isFeatured: json["is_featured"],
    status: json["status"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    brandId: json["brand_id"],
    userId: json["user_id"],
    ratingsAvgRating: json["ratings_avg_rating"],
    ratingsCount: json["ratings_count"],
    getGalleryImages: json["get_gallery_images"] == null
        ? []
        : List<GetGalleryImage>.from(
        json["get_gallery_images"]!.map((x) => GetGalleryImage.fromJson(x))),
    getCategory: json["get_category"] == null
        ? null
        : GetCategory.fromJson(json["get_category"]),
    getSubCategory: json["get_sub_category"] == null
        ? null
        : GetSubCategory.fromJson(json["get_sub_category"]),
    getBrand: json["get_brand"] == null ? null : GetBrand.fromJson(json["get_brand"]),
    colors: json["colors"] == null
        ? []
        : List<ProductColor>.from(json["colors"]!.map((x) => ProductColor.fromJson(x))),
    sizes: json["sizes"] == null ? [] : List<ProductSize>.from(json["sizes"]!.map((x) => ProductSize.fromJson(x))),
    additionalInfo: json["additional_info"] is Map
        ? AdditionalInfo.fromJson(json["additional_info"])
        : null,
    additionalInfoRaw:
    json["additional_info"] is String ? json["additional_info"] : null,
    variants: json["variants"] == null ? [] : List<ProductVariant>.from(json["variants"]!.map((x) => ProductVariant.fromJson(x))),    getAdvertInfo: json["get_advert_info"] == null
        ? null
        : GetAdvertInfo.fromJson(json["get_advert_info"]),
    ratings: json["ratings"] == null ? [] : List<ProductRating>.from(json["ratings"]!.map((x) => ProductRating.fromJson(x))),
    stocks: json["stocks"] == null ? [] : List<ProductStock>.from(json["stocks"]!.map((x) => ProductStock.fromJson(x))),
    getProductUser: json["get_product_user"] == null
        ? null
        : GetProductUser.fromJson(json["get_product_user"]),
    slugUrl: json["slug_url"],
    shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
    listingTypeId: json["listing_type_id"],
    childCategoryId: json["child_category_id"],
    shopId: json["shop_id"],
    discountPercent: json["discount_percent"],
    shippingClass: json["shipping_class"],
    deliveryTime: json["delivery_time"],
    tags: json["tags"],
    isFavorite: json["is_favorite"],
    createdAt:
    json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
    json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_title": productTitle,
    "price": price,
    "discounted_price": discountedPrice,
    "product_description": productDescription,
    "stock": stock,
    "sku": sku,
    "is_featured": isFeatured,
    "status": status,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "brand_id": brandId,
    "user_id": userId,
    "ratings_avg_rating": ratingsAvgRating,
    "ratings_count": ratingsCount,
    "get_gallery_images": getGalleryImages == null
        ? []
        : List<dynamic>.from(getGalleryImages!.map((x) => x.toJson())),
    "get_category": getCategory?.toJson(),
    "get_sub_category": getSubCategory?.toJson(),
    "get_brand": getBrand?.toJson(),
    "colors": colors == null ? [] : List<dynamic>.from(colors!.map((x) => x.toJson())),
    "sizes": sizes == null ? [] : List<dynamic>.from(sizes!.map((x) => x.toJson())),
    "additional_info": additionalInfo?.toJson() ?? additionalInfoRaw,
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x.toJson())),
    "get_advert_info": getAdvertInfo?.toJson(),
    "ratings": ratings == null ? [] : List<dynamic>.from(ratings!.map((x) => x.toJson())),
    "stocks": stocks == null ? [] : List<dynamic>.from(stocks!.map((x) => x.toJson())),
    "get_product_user": getProductUser?.toJson(),
    "slug_url": slugUrl,
    "listing_type_id": listingTypeId,
    "child_category_id": childCategoryId,
    "shop_id": shopId,
    "discount_percent": discountPercent,
    "shipping_class": shippingClass,
    "delivery_time": deliveryTime,
    "tags": tags,
    "is_favorite": isFavorite,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  ProductsItem copyWith({
    int? id,
    String? productTitle,
    String? price,
    String? discountedPrice,
    String? productDescription,
    String? stock,
    String? sku,
    int? isFeatured,
    String? status,
    int? categoryId,
    int? subCategoryId,
    int? brandId,
    int? userId,
    dynamic ratingsAvgRating,
    int? ratingsCount,
    List<GetGalleryImage>? getGalleryImages,
    GetCategory? getCategory,
    GetSubCategory? getSubCategory,
    GetBrand? getBrand,
    List<ProductColor>? colors,
    List<ProductSize>? sizes,
    AdditionalInfo? additionalInfo,
    dynamic additionalInfoRaw,
    List<ProductVariant>? variants,
    GetAdvertInfo? getAdvertInfo,
    List<ProductRating>? ratings,
    List<ProductStock>? stocks,
    GetProductUser? getProductUser,
    dynamic slugUrl,
    Shop? shop,
    dynamic listingTypeId,
    dynamic childCategoryId,
    int? shopId,
    dynamic discountPercent,
    dynamic shippingClass,
    dynamic deliveryTime,
    dynamic tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductsItem(
      id: id ?? this.id,
      productTitle: productTitle ?? this.productTitle,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      productDescription: productDescription ?? this.productDescription,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      brandId: brandId ?? this.brandId,
      userId: userId ?? this.userId,
      ratingsAvgRating: ratingsAvgRating ?? this.ratingsAvgRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      getGalleryImages: getGalleryImages ?? this.getGalleryImages,
      getCategory: getCategory ?? this.getCategory,
      getSubCategory: getSubCategory ?? this.getSubCategory,
      getBrand: getBrand ?? this.getBrand,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      additionalInfoRaw: additionalInfoRaw ?? this.additionalInfoRaw,
      variants: variants ?? this.variants,
      getAdvertInfo: getAdvertInfo ?? this.getAdvertInfo,
      ratings: ratings ?? this.ratings,
      stocks: stocks ?? this.stocks,
      getProductUser: getProductUser ?? this.getProductUser,
      slugUrl: slugUrl ?? this.slugUrl,
      shop: shop ?? this.shop,
      listingTypeId: listingTypeId ?? this.listingTypeId,
      childCategoryId: childCategoryId ?? this.childCategoryId,
      shopId: shopId ?? this.shopId,
      discountPercent: discountPercent ?? this.discountPercent,
      shippingClass: shippingClass ?? this.shippingClass,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AdditionalInfo {
  final int? id;
  final String? description;
  final String? additionalInfo;
  final String? specification;
  final int? productId;

  AdditionalInfo({
    this.id,
    this.description,
    this.additionalInfo,
    this.specification,
    this.productId,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
    id: json["id"],
    description: json["description"],
    additionalInfo: json["additional_info"],
    specification: json["specification"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "additional_info": additionalInfo,
    "specification": specification,
    "product_id": productId,
  };

  AdditionalInfo copyWith({
    int? id,
    String? description,
    String? additionalInfo,
    String? specification,
    int? productId,
  }) {
    return AdditionalInfo(
      id: id ?? this.id,
      description: description ?? this.description,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      specification: specification ?? this.specification,
      productId: productId ?? this.productId,
    );
  }
}



/*class AdditionalInfo {
  final int? id;
  final String? description;
  final List<Map<String, dynamic>> additionalInfo;
  final List<Map<String, dynamic>> specification;
  final int? productId;

  AdditionalInfo({
    this.id,
    this.description,
    this.additionalInfo = const [],
    this.specification = const [],
    this.productId,
  });

  AdditionalInfo copyWith({
    int? id,
    String? description,
    List<Map<String, dynamic>>? additionalInfo,
    List<Map<String, dynamic>>? specification,
    int? productId,
  }) =>
      AdditionalInfo(
        id: id ?? this.id,
        description: description ?? this.description,
        additionalInfo: additionalInfo ?? this.additionalInfo,
        specification: specification ?? this.specification,
        productId: productId ?? this.productId,
      );

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedAdditionalInfo = [];
    if (json["additional_info"] != null && json["additional_info"] != "") {
      parsedAdditionalInfo =
      List<Map<String, dynamic>>.from(jsonDecode(json["additional_info"]));
    }

    List<Map<String, dynamic>> parsedSpecification = [];
    if (json["specification"] != null && json["specification"] != "") {
      parsedSpecification =
      List<Map<String, dynamic>>.from(jsonDecode(json["specification"]));
    }

    return AdditionalInfo(
      id: json["id"],
      description: json["description"],
      additionalInfo: parsedAdditionalInfo,
      specification: parsedSpecification,
      productId: json["product_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "additional_info": jsonEncode(additionalInfo),
    "specification": jsonEncode(specification),
    "product_id": productId,
  };
}*/


class ProductColor {
  final int? id;
  final String? color;
  final String? colorName;
  final int? stock;
  final int? productId;
  final List<dynamic>? images;

  ProductColor({this.id, this.color, this.colorName, this.stock, this.productId, this.images});

  factory ProductColor.fromJson(Map<String, dynamic> json) => ProductColor(
    id: json["id"],
    color: json["color"],
    colorName: json["color_name"],
    stock: json["stock"],
    productId: json["product_id"],
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "color": color,
    "color_name": colorName,
    "stock": stock,
    "product_id": productId,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
  };

  ProductColor copyWith({
    int? id,
    String? color,
    String? colorName,
    int? stock,
    int? productId,
    List<dynamic>? images,
  }) {
    return ProductColor(
      id: id ?? this.id,
      color: color ?? this.color,
      colorName: colorName ?? this.colorName,
      stock: stock ?? this.stock,
      productId: productId ?? this.productId,
      images: images ?? this.images,
    );
  }
}

class GetAdvertInfo {
  final int? id;
  final int? productId;

  GetAdvertInfo({this.id, this.productId});

  factory GetAdvertInfo.fromJson(Map<String, dynamic> json) => GetAdvertInfo(
    id: json["id"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
  };

  GetAdvertInfo copyWith({int? id, int? productId}) {
    return GetAdvertInfo(
      id: id ?? this.id,
      productId: productId ?? this.productId,
    );
  }
}

class GetBrand {
  final int? id;
  final String? brandName;

  GetBrand({this.id, this.brandName});

  factory GetBrand.fromJson(Map<String, dynamic> json) => GetBrand(
    id: json["id"],
    brandName: json["brand_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_name": brandName,
  };

  GetBrand copyWith({int? id, String? brandName}) {
    return GetBrand(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
    );
  }
}

class GetCategory {
  final int? id;
  final String? categoryName;

  GetCategory({this.id, this.categoryName});

  factory GetCategory.fromJson(Map<String, dynamic> json) => GetCategory(
    id: json["id"],
    categoryName: json["category_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_name": categoryName,
  };

  GetCategory copyWith({int? id, String? categoryName}) {
    return GetCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

class GetGalleryImage {
  final int? id;
  final int? productId;
  final String? img;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetGalleryImage({
    this.id,
    this.productId,
    this.img,
    this.createdAt,
    this.updatedAt,
  });

  factory GetGalleryImage.fromJson(Map<String, dynamic> json) => GetGalleryImage(
    id: json["id"],
    productId: json["product_id"],
    img: json["img"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "img": img,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  GetGalleryImage copyWith({
    int? id,
    int? productId,
    String? img,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GetGalleryImage(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      img: img ?? this.img,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GetProductUser {
  final int? id;
  final String? name;
  final String? profileImg;
  final String? userType;

  GetProductUser({this.id, this.name, this.profileImg, this.userType});

  factory GetProductUser.fromJson(Map<String, dynamic> json) => GetProductUser(
    id: json["id"],
    name: json["name"],
    profileImg: json["profile_img"],
    userType: json["user_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_img": profileImg,
    "user_type": userType,
  };

  GetProductUser copyWith({
    int? id,
    String? name,
    String? profileImg,
    String? userType,
  }) {
    return GetProductUser(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImg: profileImg ?? this.profileImg,
      userType: userType ?? this.userType,
    );
  }
}

class GetSubCategory {
  final int? id;
  final String? subCategoryName;

  GetSubCategory({this.id, this.subCategoryName});

  factory GetSubCategory.fromJson(Map<String, dynamic> json) => GetSubCategory(
    id: json["id"],
    subCategoryName: json["sub_category_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sub_category_name": subCategoryName,
  };

  GetSubCategory copyWith({int? id, String? subCategoryName}) {
    return GetSubCategory(
      id: id ?? this.id,
      subCategoryName: subCategoryName ?? this.subCategoryName,
    );
  }
}

class Shop {
  final int? id;
  final String? name;
  final String? slug;

  Shop({this.id, this.name, this.slug});

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
  };

  Shop copyWith({int? id, String? name, String? slug}) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }
}

class ProductSize {
  final int? id;
  final String? size;
  final int? stock;
  final int? productId;

  ProductSize({
    this.id,
    this.size,
    this.stock,
    this.productId,
  });

  ProductSize copyWith({
    int? id,
    String? size,
    int? stock,
    int? productId,
  }) =>
      ProductSize(
        id: id ?? this.id,
        size: size ?? this.size,
        stock: stock ?? this.stock,
        productId: productId ?? this.productId,
      );

  factory ProductSize.fromJson(Map<String, dynamic> json) => ProductSize(
    id: json["id"],
    size: json["size"],
    stock: json["stock"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "size": size,
    "stock": stock,
    "product_id": productId,
  };
}

class ProductStock {
  final int? id;
  final int? productId;
  final dynamic variantId;
  final int? colorId;
  final int? sizeId;
  final String? sku;
  final int? stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductStock({
    this.id,
    this.productId,
    this.variantId,
    this.colorId,
    this.sizeId,
    this.sku,
    this.stock,
    this.createdAt,
    this.updatedAt,
  });

  ProductStock copyWith({
    int? id,
    int? productId,
    dynamic variantId,
    int? colorId,
    int? sizeId,
    String? sku,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProductStock(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        variantId: variantId ?? this.variantId,
        colorId: colorId ?? this.colorId,
        sizeId: sizeId ?? this.sizeId,
        sku: sku ?? this.sku,
        stock: stock ?? this.stock,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory ProductStock.fromJson(Map<String, dynamic> json) => ProductStock(
    id: json["id"],
    productId: json["product_id"],
    variantId: json["variant_id"],
    colorId: json["color_id"],
    sizeId: json["size_id"],
    sku: json["sku"],
    stock: json["stock"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "variant_id": variantId,
    "color_id": colorId,
    "size_id": sizeId,
    "sku": sku,
    "stock": stock,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class ProductVariant {
  final int? id;
  final String? variantName;
  final String? price;
  final String? discountedPrice;
  final int? stock;
  final int? productId;

  ProductVariant({
    this.id,
    this.variantName,
    this.price,
    this.discountedPrice,
    this.stock,
    this.productId,
  });

  ProductVariant copyWith({
    int? id,
    String? variantName,
    String? price,
    String? discountedPrice,
    int? stock,
    int? productId,
  }) =>
      ProductVariant(
        id: id ?? this.id,
        variantName: variantName ?? this.variantName,
        price: price ?? this.price,
        discountedPrice: discountedPrice ?? this.discountedPrice,
        stock: stock ?? this.stock,
        productId: productId ?? this.productId,
      );

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json["id"],
    variantName: json["variant_name"],
    price: json["price"],
    discountedPrice: json["discounted_price"],
    stock: json["stock"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "variant_name": variantName,
    "price": price,
    "discounted_price": discountedPrice,
    "stock": stock,
    "product_id": productId,
  };
}

class ProductRating {
  final int? id;
  final int? rating;
  final String? message;
  final int? productId;
  final int? userId;
  final DateTime? createdAt;
  final User? user;

  ProductRating({
    this.id,
    this.rating,
    this.message,
    this.productId,
    this.userId,
    this.createdAt,
    this.user,
  });

  ProductRating copyWith({
    int? id,
    int? rating,
    String? message,
    int? productId,
    int? userId,
    DateTime? createdAt,
    User? user,
  }) =>
      ProductRating(
        id: id ?? this.id,
        rating: rating ?? this.rating,
        message: message ?? this.message,
        productId: productId ?? this.productId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        user: user ?? this.user,
      );

  factory ProductRating.fromJson(Map<String, dynamic> json) => ProductRating(
    id: json["id"],
    rating: json["rating"],
    message: json["message"],
    productId: json["product_id"],
    userId: json["user_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rating": rating,
    "message": message,
    "product_id": productId,
    "user_id": userId,
    "created_at": createdAt?.toIso8601String(),
    "user": user?.toJson(),
  };
}

import { getCart, getCartDetails } from "@/actions/cart";
import CheckoutItem from "@/components/shoppingCart/CheckoutItem";
import Container from "@/components/shared/Container";
import PlaceOrder from "@/components/shoppingCart/PlaceOrder";
import { getSingleProduct, getActiveCard } from "@/actions/product";
import Image from "next/image";
import AddressNote from "@/components/shoppingCart/AddressNote";

export const metadata = {
  title: "Checkout",
  robots: { index: false },
};

const CheckoutPage = async ({ searchParams }) => {
  console.log("CheckOut");
  let product, data, cartDetails;
  let selectedVariant;
  let isCard = false;
  const product_id = searchParams["product_id"];
  const variant = searchParams["variant"];
  const quantity = searchParams["quantity"];

  if (product_id) {
    // Try to get as card first (since Buy Now from cards passes card_id as product_id)
    const cardData = await getActiveCard(product_id);
    console.log("cardData", cardData);
    if (cardData?.data) {
      // Normalize card data to match product structure
      const card = cardData.data;
      product = {
        ...card,
        user_id: card.seller?.id, // Map seller.id to user_id for compatibility
        product_title: card.card_title, // Map card_title to product_title
        discounted_price: card.price, // Cards don't have discounts, use price
        price: card.price,
        get_gallery_images: card.images?.map(img => ({ img })) || [], // Map images to gallery format
      };
      isCard = true;
    } else {
      // If not a card, try to get as regular product
      const productData = await getSingleProduct(product_id);
      console.log("productData", productData);
      if (productData?.data) {
        product = productData.data;
        isCard = false;
      } else {
        console.error("Neither card nor product found for ID:", product_id);
        // You might want to redirect to an error page or show an error message
      }
    }
  } else {
    let cartResponse, cartDetailsResponse;
    try {
      [cartResponse, cartDetailsResponse] = await Promise.all([
        getCart(),
        getCartDetails(),
      ]);
    } catch (error) {
      console.error("Error fetching cart data:", error);
      cartResponse = { status: "error", data: null };
      cartDetailsResponse = { status: "error", data: null };
    }

    // Extract data from response - API returns { status, data }
    const cartData = cartResponse?.status === 'success' ? cartResponse?.data : (cartResponse?.data || null);
    cartDetails = cartDetailsResponse?.status === 'success' ? cartDetailsResponse?.data : (cartDetailsResponse?.data || null);

    // Combine products and cards into a single array
    const allItems = [];
    if (cartData?.products && Array.isArray(cartData.products)) {
      cartData.products.forEach((item) => {
        allItems.push({ ...item, itemType: 'product' });
      });
    }
    if (cartData?.cards && Array.isArray(cartData.cards)) {
      cartData.cards.forEach((item) => {
        // For cards, we need to format them properly with card data
        const cardData = item.card || item; // Get the SellerInventory data
        allItems.push({ 
          id: item.id,
          card_id: item.card_id,
          card: cardData,
          itemType: 'card',
          quantity: 1
        });
      });
    }

    // Fallback to items array if provided (from backend update)
    data = (cartData?.items && Array.isArray(cartData.items)) ? cartData.items : allItems;
  }

  if (variant)
    selectedVariant = product?.variants?.find((item) => item.id == variant);

  return (
    <section>
      <Container>
        <div className="min-h-[calc(100vh-204px)]">
          <div className="grid grid-cols-1 lg:grid-cols-[2fr_1fr] gap-6 mt-12">
            {/* -------------------shipping-information---------------- */}
            <AddressNote />
            {/* -------------------order-summary---------------- */}
            <div>
              <div className="border border-border rounded-[4px] p-6">
                <p className="text-lg font-medium">Order Summary</p>
                {product_id ? (
                  <div className="h-16 flex items-center gap-4 mt-5">
                    <Image
                      src={`${process.env.NEXT_PUBLIC_IMG_URL}/${isCard ? product?.images?.[0] : product?.get_gallery_images?.[0]?.img}`}
                      alt="#"
                      width={64}
                      height={64}
                      className="object-cover"
                    />
                    <div>
                      <p className="text-sm line-clamp-1">
                        {isCard ? product?.card_title : product?.product_title}
                      </p>
                      <p className="text-sm">
                        <span className="text-tGray">
                          {product_id ? quantity : data?.quantity} x{" "}
                        </span>
                        <span className="text-skyBlue font-semibold">
                          $
                          {product_id && variant
                            ? selectedVariant?.discounted_price
                            : product_id
                            ? (isCard ? product?.price : product?.price)
                            : product?.discounted_price}
                        </span>
                      </p>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-4 mt-5">
                    {data && Array.isArray(data) && data.length > 0 ? (
                      data.map((item) => (
                        <CheckoutItem key={item.id} data={item} />
                      ))
                    ) : (
                      <p className="text-gray-500 text-sm">Your cart is empty</p>
                    )}
                  </div>
                )}
                <div className="space-y-3 mt-5 text-sm">
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Sub-total</span>
                    <span>
                      $
                      {product_id && variant
                        ? parseFloat(selectedVariant?.discounted_price || 0).toFixed(2)
                        : product_id
                        ? parseFloat(isCard ? product?.price : product?.price || 0).toFixed(2)
                        : parseFloat(cartDetails?.sub_total || 0).toFixed(2)}
                    </span>
                  </p>
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Shipping</span>
                    <span>Free</span>
                  </p>
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Platform Fee (4%)</span>
                    <span>
                      $
                      {product_id
                        ? 0 // Platform fee only applies to cart checkout
                        : parseFloat(cartDetails?.platform_fee || 0).toFixed(2)}
                    </span>
                  </p>
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Tax</span>
                    <span>${product_id ? parseFloat(0).toFixed(2) : parseFloat(cartDetails?.tax || 0).toFixed(2)}</span>
                  </p>
                </div>
                <hr className="my-4" />
                <p className="flex justify-between items-center text-base">
                  <span className="text-tGray">Total</span>
                  <span className="font-semibold">
                    $
                    {product_id && quantity && variant
                      ? (parseFloat(selectedVariant?.discounted_price || 0) * parseInt(quantity || 1)).toFixed(2)
                      : product_id
                      ? isCard 
                        ? (parseFloat(product?.price || 0) * parseInt(quantity || 1)).toFixed(2)
                        : (parseFloat(product?.discounted_price || 0) * parseInt(quantity || 1)).toFixed(2)
                      : parseFloat(cartDetails?.total_price || 0).toFixed(2)}
                  </span>
                </p>
                <PlaceOrder product={product} />
              </div>
            </div>
          </div>
        </div>
      </Container>
    </section>
  );
};

export default CheckoutPage;

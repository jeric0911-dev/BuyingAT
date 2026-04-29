import { getCart, getCartDetails } from "@/actions/cart";
import Container from "@/components/shared/Container";
import CartItem from "@/components/shoppingCart/CartItem";
import Image from "next/image";
import { Link } from "next-view-transitions";

export const metadata = {
  title: "Shopping Cart",
  robots: { index: false },
};
export const dynamic = "force-dynamic";

const ShoppingCartPage = async () => {
  console.log("CheckOut");
  
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
  const data = cartResponse?.status === 'success' ? cartResponse?.data : (cartResponse?.data || null);
  const cartDetails = cartDetailsResponse?.status === 'success' ? cartDetailsResponse?.data : (cartDetailsResponse?.data || null);

  console.log("Cart response:", cartResponse);
  console.log("Cart data:", data);
  
  // Combine products and cards into a single array
  const allItems = [];
  if (data?.products && Array.isArray(data.products)) {
    data.products.forEach((item) => {
      allItems.push({ ...item, itemType: 'product' });
    });
  }
  if (data?.cards && Array.isArray(data.cards)) {
    data.cards.forEach((item) => {
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
  const cartItems = (data?.items && Array.isArray(data.items)) ? data.items : allItems;

  console.log("Final cart items:", cartItems);

  return (
    <main>
      <Container>
        <div className="min-h-[calc(100vh-204px)]">
          <div className="grid grid-cols-1 lg:grid-cols-[2fr_1fr] gap-6 mt-12">
            {/* -------------------shopping-cart---------------- */}
            <div className="border border-border rounded-[4px] h-max">
              <p className="px-6 py-5 text-lg font-medium">Shopping Cart</p>
              <div className="overflow-x-auto scrollbar-hide">
                <table className="w-full">
                  <thead className="bg-[#F5F7F9]">
                    <tr>
                      <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">
                        Card
                      </th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">
                        Price
                      </th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">
                        Total
                      </th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">
                        Action
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {cartItems && cartItems.length > 0 ? (
                      cartItems.map((item) => (
                        <CartItem key={item.id} data={item} />
                      ))
                    ) : (
                      <tr>
                        <td colSpan={5} className="px-6 py-8 text-center text-gray-500">
                          Your cart is empty
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
            {/* -------------------order-summary---------------- */}
            <div>
              <div className="border border-border rounded-[4px] p-6">
                <p className="text-lg font-medium">Order Summary</p>
                <div className="space-y-3 mt-5 text-sm">
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Sub-total</span>
                    <span>${parseFloat(cartDetails?.sub_total || 0).toFixed(2)}</span>
                  </p>
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Shipping</span>
                    <span>Free</span>
                  </p>
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Platform Fee (4%)</span>
                    <span>${parseFloat(cartDetails?.platform_fee || 0).toFixed(2)}</span>
                  </p>
                  <p className="flex justify-between items-center">
                    <span className="text-tGray">Tax</span>
                    <span>${parseFloat(cartDetails?.tax || 0).toFixed(2)}</span>
                  </p>
                </div>
                <hr className="my-4" />
                <p className="flex justify-between items-center text-base">
                  <span className="text-tGray">Total</span>
                  <span className="font-semibold">${parseFloat(cartDetails?.total_price || 0).toFixed(2)}</span>
                </p>
                <Link
                  href="/shopping-cart/checkout"
                  className="w-full bg-skyBlue text-white py-3 px-6 rounded mt-4 block text-center hover:bg-green-600 transition-colors"
                >
                  Proceed to Checkout
                </Link>
              </div>
            </div>
          </div>
        </div>
      </Container>
    </main>
  );
};

export default ShoppingCartPage;

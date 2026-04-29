import Image from "next/image";

const ProductRow = ({ data }) => {
  // Prefer card data when available (card orders), otherwise fallback to product
  const cardImg = data?.card?.images?.[0]
    ? `${process.env.NEXT_PUBLIC_IMG_URL}/${data.card.images[0]}`
    : null;
  const productImg = data?.product?.get_gallery_images?.[0]?.img
    ? `${process.env.NEXT_PUBLIC_IMG_URL}/${data.product.get_gallery_images[0].img}`
    : null;
  const imageSrc = cardImg || productImg || '/placeholder.png';

  const title = data?.card?.card_title || data?.product?.product_title || '';
  const category = data?.card?.sport_type || data?.product?.category?.category_name || '';

  const priceNum = Number(data?.price) || 0;
  const platformFee = priceNum * 0.04;
  const tax = priceNum * 0.10;
  const subTotal = priceNum + platformFee + tax;

  return (
    <div className="grid grid-cols-[1fr_124px_124px_124px_150px] gap-5 text-sm py-4">
      <div className="flex items-center gap-3 h-full pr-10">
        <Image src={imageSrc} alt="#" width={80} height={80} className="object-cover" />
        <div>
          <p className="text-skyBlue text-xs font-semibold text-wrap uppercase">
            {category}
          </p>
          <p className="text-tGray line-clamp-2 mt-1">
            {title}
          </p>
        </div>
      </div>
      <div className="h-full leading-[80px] text-tGray">${priceNum.toFixed(2)}</div>
      <div className="h-full leading-[80px] text-tGray">${platformFee.toFixed(2)}</div>
      <div className="h-full leading-[80px] text-tGray">${tax.toFixed(2)}</div>
      <div className="h-full leading-[80px] font-medium">${subTotal.toFixed(2)}</div>
    </div>
  );
};

export default ProductRow;

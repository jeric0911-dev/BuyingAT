"use client";

import Image from "next/image";

const CheckoutItem = ({ data }) => {
  const isCard = data?.itemType === 'card';

  // For products
  if (!isCard) {
    return (
      <div className="h-16 flex items-center gap-4">
        <Image
          src={`${process.env.NEXT_PUBLIC_IMG_URL}/${data?.product?.get_gallery_images?.[0]?.img}`}
          alt={data?.product?.product_title}
          width={64}
          height={64}
          className="object-cover rounded"
        />
        <div className="flex-1">
          <p className="text-sm line-clamp-1">{data?.product?.product_title}</p>
          <p className="text-sm">
            <span className="text-tGray">Qty: {data?.quantity || 1} x </span>
            <span className="text-skyBlue font-semibold">${parseFloat(data?.price || 0).toFixed(2)}</span>
          </p>
        </div>
      </div>
    );
  }

  // For cards
  const card = data?.card;
  const cardImage = card?.images && Array.isArray(card.images) && card.images.length > 0 
    ? card.images[0] 
    : (card?.images && typeof card.images === 'string' ? card.images : null);

  return (
    <div className="h-16 flex items-center gap-4">
      <Image
        src={cardImage ? `${process.env.NEXT_PUBLIC_IMG_URL}/${cardImage}` : '/placeholder-card.png'}
        alt={card?.card_title || 'Card'}
        width={64}
        height={64}
        className="object-cover rounded"
      />
      <div className="flex-1">
        <p className="text-sm line-clamp-1">{card?.card_title || 'Card'}</p>
        <p className="text-sm">
          {/* <span className="text-tGray">Qty: {data?.quantity || 1} x </span> */}
          <span className="text-skyBlue font-semibold">${parseFloat(card?.price || 0).toFixed(2)}</span>
        </p>
      </div>
    </div>
  );
};

export default CheckoutItem;

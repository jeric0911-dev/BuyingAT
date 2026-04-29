import Image from "next/image";

const PaymentOption = ({ src, title }) => {
  return (
    <label className="flex flex-col justify-center items-center">
      <Image src={src} alt="#" width={32} height={32} />
      <p className="mt-2 text-sm text-center font-medium">{title}</p>
      <input
        type="radio"
        name="payment"
        className="size-5 form-radio border-border text-skyBlue focus:ring-0 mt-4"
      />
    </label>
  );
};

export default PaymentOption;

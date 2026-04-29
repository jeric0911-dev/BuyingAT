import Image from "next/image";

const OrderStatus = ({ status }) => {
  return (
    <ul className="flex justify-between px-1 sm:px-20 mt-10">
      <li>
        <div
          className={`rounded-full border-2 flex items-center justify-center transition duration-300 relative text-white size-7 ${
            status >= 1 && "bg-skyBlue"
          } border-skyBlue`}
        >
          {status >= 1 && <span className="text-xs">&#10003;</span>}
        </div>
        <div className="relative h-16 mt-6">
          <Image
            src="/icon/notebook.svg"
            alt="#"
            width={32}
            height={32}
            className={`${status < 1 && "opacity-50"}`}
          />
          <p
            className={`absolute left-1/2 -translate-x-1/2  whitespace-nowrap mt-2 text-sm font-medium ${
              status < 1 && "text-tGray"
            }`}
          >
            Order Placed
          </p>
        </div>
      </li>
      <li className="flex w-full justify-start items-center relative h-7">
        <div
          className={`absolute border-t-8 w-full z-0 ${
            status >= 1 ? "border-skyBlue" : "border-skyBlue/50"
          } rounded-l-full rounded-r-full`}
        ></div>
      </li>
      {/* Removed Packaging step */}
      <li>
        <div
          className={`rounded-full border-2 flex items-center justify-center transition duration-300 relative text-white size-7 ${
            status >= 2 && "bg-skyBlue"
          } border-skyBlue`}
        >
          {status >= 2 && <span className="text-xs">&#10003;</span>}
        </div>
        <div className="relative h-16 mt-6">
          <Image
            src="/icon/truck.svg"
            alt="#"
            width={32}
            height={32}
            className={`${status < 2 && "opacity-50"}`}
          />
          <p
            className={`absolute left-1/2 -translate-x-1/2  whitespace-nowrap mt-2 text-sm font-medium ${
              status < 2 && "text-tGray"
            }`}
          >
            On The Road
          </p>
        </div>
      </li>
      <li className="flex w-full justify-start items-center relative h-7">
        <div
          className={`absolute border-t-8 w-full z-0 ${
            status >= 2 ? "border-skyBlue" : "border-skyBlue/50"
          } rounded-l-full rounded-r-full`}
        ></div>
      </li>
      <li>
        <div
          className={`rounded-full border-2 flex items-center justify-center transition duration-300 relative text-white size-7 ${
            status >= 3 && "bg-skyBlue"
          } border-skyBlue`}
        >
          {status >= 3 && <span className="text-xs">&#10003;</span>}
        </div>
        <div className="relative h-16 mt-6">
          <Image
            src="/icon/handshake.svg"
            alt="#"
            width={32}
            height={32}
            className={`${status < 3 && "opacity-50"}`}
          />
          <p
            className={`absolute left-1/2 -translate-x-1/2  whitespace-nowrap mt-2 text-sm font-medium ${
              status < 3 && "text-tGray"
            }`}
          >
            Delivered
          </p>
        </div>
      </li>
    </ul>
  );
};

export default OrderStatus;

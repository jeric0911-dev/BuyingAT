import dayjs from "dayjs";
import Image from "next/image";

const OrderActivity = ({ data }) => {
  return (
    <section className="border border-border rounded px-6 py-8">
      <p className="text-lg font-medium mb-6">Order Activity</p>
      <div className="space-y-4">
        {data?.order_status_detail?.map((item) => (
          <div key={item.id} className="flex items-center gap-4">
            <div
              className={`flex justify-center items-center border rounded-sm p-3 ${
                item?.status === "delivered"
                  ? "border-green/30 bg-green/10"
                  : item?.status === "cancelled"
                  ? "border-redPink/30 bg-redPink/10"
                  : "border-skyBlue/30 bg-skyBlue/10"
              }`}
            >
              <Image
                src={
                  item?.status === "placed"
                    ? "/icon/notepad.svg"
                    : item?.status === "packaging"
                    ? "/icon/mapTrifold.svg"
                    : item?.status === "on_the_way"
                    ? "/icon/userBlue.svg"
                    : item?.status === "delivered"
                    ? "/icon/checks.svg"
                    : item?.status === "cancelled"
                    ? "/icon/crossCircle.svg"
                    : ""
                }
                alt="#"
                width={24}
                height={24}
              />
            </div>
            <div>
              <p className="text-sm capitalize text-tBlack">{item?.message}</p>
              <p className="text-sm text-tGray mt-2">
                {dayjs(item.created_at).format("DD MMM, YYYY [at] h:mm A")}
              </p>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
};

export default OrderActivity;

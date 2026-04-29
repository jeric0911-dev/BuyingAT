import { Link } from "next-view-transitions";
import { tableHead } from "@/constants";
import { getTransactions, getWallet } from "@/actions/others";
import relativeTime from "dayjs/plugin/relativeTime";
import dayjs from "dayjs";
dayjs.extend(relativeTime);

export const metadata = {
  title: "Wallet",
  robots: { index: false },
};

const WalletPage = async () => {
  const [{ data: wallet }, { data: transactions }] = await Promise.all([
    getWallet(),
    getTransactions(),
  ]);

  return (
    <main className="w-full overflow-hidden">
      <section className="text-skyBlue">
        <p className="text-tBlack text-xl font-semibold">Wallet Info</p>
        <div className="mt-5 grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="wallet-card">
            <p>Balance</p>
            <p className="relative">
              {wallet?.balance}
              <span>Credit</span>
              <Link
                href="/deposit"
                className="absolute bottom-1.5 right-0 text-white rounded-md text-sm font-semibold bg-skyBlue py-2 px-4"
              >
                Recharge
              </Link>
            </p>
          </div>
          <div className="wallet-card">
            <p>Expense</p>
            <p>
              {wallet?.expense}
              <span>Credit</span>
            </p>
          </div>
          <div className="wallet-card">
            <p>Last Recharge</p>
            <p>
              {/* {firstSuccess ? Number.parseInt(firstSuccess?.amount) : 0} */}
              {wallet?.last_recharge}
              <span>Credit</span>
            </p>
          </div>
        </div>
      </section>

      <section className="overflow-x-auto">
        <div className="inline-block min-w-full rounded border border-border overflow-hidden mt-6">
          <table className="table-auto min-w-full">
            <thead>
              <tr>
                {tableHead.map((item) => (
                  <th
                    key={item}
                    className="px-5 py-4 bg-skyBlue/5 text-skyBlue font-bold border-b border-skyBlue/30"
                  >
                    {item}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {transactions?.map((item) => (
                <tr
                  key={item.id}
                  className="border-b last:border-b-0 border-dashed border-tGray/50"
                >
                  <td className="text-center py-5 text-sm [&>div>p:first-child]:font-semibold [&>div>p:first-child]:text-tBlack [&>div>p:nth-child(2)]:font-medium [&>div>p:nth-child(2)]:text-tGray">
                    <div>
                      <p>{item?.payment_method}</p>
                      <p className="text-sm font-medium text-tGray">
                        {item?.transaction_id}
                      </p>
                    </div>
                  </td>
                  <td className="text-center py-5 text-sm [&>div>p:first-child]:font-semibold [&>div>p:first-child]:text-tBlack [&>div>p:nth-child(2)]:font-medium [&>div>p:nth-child(2)]:text-tGray">
                    <div>
                      <p>
                        {dayjs(item?.created_at).format("YYYY-MM-DD hh:mm A")}
                      </p>
                      <p>{dayjs(item?.created_at).fromNow()}</p>
                    </div>
                  </td>
                  <td className="text-center py-5 text-sm font-semibold text-tBlack">
                    {item?.credits || 0}{" "}
                    <span className="text-[10px] font-bold text-tGray">
                      credit
                    </span>
                  </td>
                  <td className="text-center py-5 text-sm font-semibold [&>div>p:first-child]:text-tGray [&>div>p:nth-child(2)]:text-tBlack">
                    <p>{item?.conversion}</p>
                    <p className="mt-1 font-semibold">
                      {item?.amount} {item?.currency}
                    </p>
                  </td>
                  <td className="text-center py-4">
                    <div
                      className={`text-xs font-bold ${
                        item?.status === "success"
                          ? "text-[#0DBB68] bg-[#0DBB68]/10"
                          : "text-[#E46A11] bg-[#E46A11]/10"
                      } w-20 py-1.5 rounded-lg capitalize`}
                    >
                      {item?.status}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </main>
  );
};

export default WalletPage;

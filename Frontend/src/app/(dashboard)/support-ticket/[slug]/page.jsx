import { getUser } from "@/actions/auth";
import { getTicketDetails } from "@/actions/vendor";
import CloseTicketButton from "@/components/supportTicket/CloseTicketButton";
import MessageCard from "@/components/supportTicket/MessageCard";
import ReplayMessageForm from "@/components/supportTicket/ReplayMessageForm";

export const metadata = {
  title: "View Ticket",
  robots: { index: false },
};

const TicketDetailsPage = async ({ params: { slug } }) => {
  const { data } = await getTicketDetails(slug)

  return (
    <section>
      <div className="border border-border rounded-sm">
        <div className="border-b border-border flex justify-between items-center px-5 py-3">
          <p>{data?.[0]?.support_ticket?.ticket_id}</p>
          {!data?.[0]?.support_ticket?.status ? (
            <button className="text-red-500 bg-red-100 border border-red-500 px-3 py-2 text-xs rounded-md pointer-events-none">
              Closed
            </button>
          ) : (
            <CloseTicketButton data={data} />
          )}
        </div>
        <ReplayMessageForm data={data} />
      </div>
      {data?.length > 0 && (
        <div className="border border-border p-5 rounded-sm space-y-4 mt-5">
          {data?.map((item) => (
            <MessageCard key={item.id} data={item} />
          ))}
        </div>
      )}
    </section>
  );
};

export default TicketDetailsPage;

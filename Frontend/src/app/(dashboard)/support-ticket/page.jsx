import { getSupportTickets } from "@/actions/vendor";
import TicketTable from "@/components/supportTicket/TicketTable";

export const metadata = {
  title: "Support Tickets",
  robots: { index: false },
};

const SupportTicketPage = async () => {
  const { data } = await getSupportTickets();

  return (
    <section className="border border-border rounded overflow-hidden">
      <TicketTable data={data} />
    </section>
  );
};

export default SupportTicketPage;

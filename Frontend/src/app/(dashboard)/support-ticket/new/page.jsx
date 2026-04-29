import CreateTicketForm from "@/components/supportTicket/CreateTicketForm";

export const metadata = {
  title: "Create New Ticket",
  robots: { index: false },
};

const NewTicketPage = () => {
  return (
    <section className="lg:border border-border rounded lg:p-5 overflow-hidden">
      <CreateTicketForm />
    </section>
  );
};

export default NewTicketPage;

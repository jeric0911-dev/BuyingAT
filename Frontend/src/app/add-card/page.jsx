import AddCardForm from "@/components/addCard/AddCardForm";
import Container from "@/components/shared/Container";

export const metadata = {
  title: "Add Card",
  description: "Add a new card to your listings",
  robots: { index: false },
};

const AddCardPage = () => {
  return (
    <section className="mt-10">
      <Container>
        <p className="px-6 py-4 border border-border rounded text-sm font-medium">
          CREATE NEW CARD
        </p>
        <AddCardForm />
      </Container>
    </section>
  );
};

export default AddCardPage;

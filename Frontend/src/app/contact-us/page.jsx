import Container from "@/components/shared/Container";
import ContactForm from "./ContactForm";

const ContactUsPage = () => {
  return (
    <section>
      <Container>
        <div className="min-h-[calc(100vh-300px)] flex justify-center items-center">
          <ContactForm />
        </div>
      </Container>
    </section>
  );
};

export default ContactUsPage;

import Container from "@/components/shared/Container";

const CardDetailLoading = () => {
  return (
    <main className="mt-10">
      <Container>
        <section className="grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-0">
          <div className="lg:pr-14">
            <div className="animate-pulse">
              <div className="bg-gray-200 h-96 rounded"></div>
            </div>
          </div>
          <div className="">
            <div className="animate-pulse space-y-4">
              <div className="h-8 bg-gray-200 rounded w-3/4"></div>
              <div className="h-4 bg-gray-200 rounded w-1/2"></div>
              <div className="h-4 bg-gray-200 rounded w-1/3"></div>
              <div className="h-6 bg-gray-200 rounded w-1/4"></div>
              <div className="h-4 bg-gray-200 rounded w-full"></div>
              <div className="h-4 bg-gray-200 rounded w-full"></div>
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            </div>
          </div>
        </section>
      </Container>
    </main>
  );
};

export default CardDetailLoading;

import ShopNow from "@/components/buttons/ShopNow";
import Container from "@/components/shared/Container";
import Image from "next/image";
import { Link } from "next-view-transitions";
import { GoStack } from "react-icons/go";

export const metadata = {
  title: "Checkout Success",
  robots: { index: false },
};

const CheckoutSuccessPage = () => {
  return (
    <main>
      <Container>
        <div className="mt-28 flex flex-col items-center justify-center">
          <Image
            src="/icon/checkCircle-fill.svg"
            alt="success"
            width={88}
            height={88}
          />
          <p className="mt-6 text-2xl font-semibold text-tBlack">
            Your order is successfully place
          </p>
          <p className="mt-3 text-tGray text-sm text-center max-w-[45ch]">
            Pellentesque sed lectus nec tortor tristique accumsan quis dictum
            risus. Donec volutpat mollis nulla non facilisis.
          </p>
          <div className="mt-8 flex items-center gap-3">
            <Link
              href={`/`}
              style={{ "--hover-bg": `black`, "--hover-txt": "white" }}
              className="btn-hover-effect px-6 py-3 rounded-sm text-skyBlue flex items-center gap-3 border border-lightOrange"
            >
              <GoStack size={20} />
              <span className="text-sm font-bold">GO TO DASHBOARD</span>
            </Link>

            <ShopNow
              text="VIEW ORDER"
              size={20}
              link={`/my-orders`}
              cls={
                "w-[140px] inline-block bg-skyBlue text-white text-sm font-bold py-3 rounded-sm"
              }
            />
          </div>
        </div>
      </Container>
    </main>
  );
};

export default CheckoutSuccessPage;

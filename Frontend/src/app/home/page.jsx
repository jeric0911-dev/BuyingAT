import BestDeals from "@/components/home/BestDeals";
import BoostedProducts from "@/components/home/BoostedProducts";
import Category from "@/components/home/Category";
import ComputerAccessories from "@/components/home/ComputerAccessories";
import FeaturedProducts from "@/components/home/FeaturedProducts";
import Hero from "@/components/home/Hero";
import LatestBlog from "@/components/home/LatestBlog";
import NewArrival from "@/components/home/NewArrival";
import TopRated from "@/components/home/TopRated";
import TwoBanner from "@/components/home/TwoBanner";
import Container from "@/components/shared/Container";

export const metadata = {
  title: "Home",
  description: "Welcome to our marketplace",
};

const HomePage = () => {
  return (
    <>
      <Hero />
      <Container>
        <BoostedProducts />
        <Category />
        <BestDeals />
        <FeaturedProducts />
        <TwoBanner />
        <ComputerAccessories />
        <TopRated />
        <NewArrival />
        <LatestBlog />
      </Container>
    </>
  );
};

export default HomePage;

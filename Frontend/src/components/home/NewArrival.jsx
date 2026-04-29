import ProductCard from "./ProductCard";
import MySliderNoGap from "../shared/MySliderNoGap";
import { getNewArrival } from "@/actions/others";

const NewArrival = async () => {
  const { data } = await getNewArrival();

  return (
    <MySliderNoGap slidesToShow={5} title="New Arrivals" link="/products">
      {data?.map((item, i) => (
        <div key={i} className="my-2">
          <ProductCard data={item} />
        </div>
      ))}
    </MySliderNoGap>
  );
};

export default NewArrival;

import ProductCard from "./ProductCard";
import MySliderNoGap from "../shared/MySliderNoGap";
import { getTopRated } from "@/actions/others";

const TopRated = async () => {
  const { data } = await getTopRated();

  return (
    <MySliderNoGap
      slidesToShow={5}
      title="Top Rated"
      link="/products?sort_by=rating&sort_direction=desc"
    >
      {data?.map((item, i) => (
        <div key={i} className="my-2">
          <ProductCard data={item} />
        </div>
      ))}
    </MySliderNoGap>
  );
};

export default TopRated;

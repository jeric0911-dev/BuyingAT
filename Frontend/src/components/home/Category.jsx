import { getShopWithCategory } from "@/actions/others";
import MySlider from "../shared/MySlider";
import CategoryCard from "./CategoryCard";

const Category = async () => {
  const { data } = await getShopWithCategory();

  return (
    <section className="mt-16">
      <p className="text-2xl font-semibold text-center">Shop with Categories</p>
      <div className="mt-10 overflow-hidden">
        <MySlider slidesToShow={5}>
          {data?.map((item, i) => (
            <div key={i} className="px-4">
              <CategoryCard data={item} />
            </div>
          ))}
        </MySlider>
      </div>
    </section>
  );
};

export default Category;

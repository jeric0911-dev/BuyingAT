import { Link } from "next-view-transitions";
import Container from "../Container";
// import CategoryMenu from "./CategoryMenu";

const CategoryBar = ({ categories }) => {
  return (
    <Container className="hidden lg:block">
      <div className="flex items-center gap-5 text-[#5F6C72] text-nowrap text-sm font-semibold">
        {/* <CategoryMenu categories={categories} /> */}
        {/* <menu className="flex gap-5 overflow-x-auto no-scrollbar">
          {categories?.slice(0, 9)?.map((item) => (
            <li key={item.id}>
              <Link
                href={`/products?category_id=${item?.id}`}
                className="py-2 px-3 inline-block hover:text-skyBlue hover:bg-lightGray"
              >
                {item?.category_name}
              </Link>
            </li>
          ))}
        </menu> */}
      </div>
    </Container>
  );
};

export default CategoryBar;

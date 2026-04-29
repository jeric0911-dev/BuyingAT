import { Link } from "next-view-transitions";
import { IoArrowForward } from "react-icons/io5";

const ShopNow = ({
  size,
  color = "black",
  text = "SHOP NOW",
  cls = "",
  link,
  ariaLabel,
}) => {
  return (
    <Link
      href={link}
      style={{ "--hover-bg": `${color}`, "--hover-txt": "white" }}
      className={`btn-hover-effect hover:border-transparent flex items-center justify-center gap-1 ${cls}`}
      aria-label={ariaLabel ?? text}
    >
      <span>{text}</span>
      <IoArrowForward size={size} />
    </Link>
  );
};

export default ShopNow;

import { Link } from "next-view-transitions";

const EditInventoryButton = ({ data }) => {
  return (
    <Link href={`/edit-inventory?id=${data?.id}`}>
      <button className="size-full text-white rounded bg-skyBlue hover:bg-skyBlue/80 transition-colors duration-200">
        Edit
      </button>
    </Link>
  );
};

export default EditInventoryButton;

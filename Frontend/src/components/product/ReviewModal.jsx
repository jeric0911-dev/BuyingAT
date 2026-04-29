import { useState } from "react";
import Modal from "../modal/Modal";
import { Rating as ReactRating, Star } from "@smastrom/react-rating";
import { giveReview } from "@/actions/product";
import { success } from "@/constants";
import { toast } from "sonner";

const myStyles = {
  itemShapes: Star,
  itemStrokeWidth: 2,
  activeFillColor: "#FA8232",
  activeStrokeColor: "#FA8232",
  inactiveFillColor: "#FFFFFF",
  inactiveStrokeColor: "#ADB7BC",
};

const ReviewModal = ({ open, setOpen, data }) => {
  const [rating, setRating] = useState(0);
  const [message, setMessage] = useState("");
  const [productId, setProductId] = useState("");

  const handleRating = async () => {
    if (!rating || !productId || !message.trim())
      return toast.error("All fields are required!");
    const selectedProduct = data?.find((item) => item.product_id === productId);
    const res = await giveReview({ rating, message, product_id: productId });
    setOpen(false);
    if (res.status === success) {
      toast.success(
        `Thanks for reviewing "${selectedProduct?.product?.product_title}"!`
      );
    } else {
      toast.error(res.message || "Something went wrong!");
    }
  };

  return (
    <Modal open={open} handleClose={{ setOpen }} title="Review">
      <div className="flex flex-col items-center">
        <p className="text-sm text-tGray">
          How would you rate this product and leave a comment bellow.
        </p>
        <ReactRating
          style={{ maxWidth: 346 }}
          itemStyles={myStyles}
          value={rating}
          onChange={setRating}
          className="mt-14"
        />
        {/* <StarRating value={4} /> */}
        <label className="block w-full mt-14 text-sm">
          Products
          <select
            onChange={(e) => setProductId(e.target.value)}
            className="mt-2 input-select"
            required
          >
            <option value="">Select Product</option>
            {data?.map((item, i) => (
              <option key={i} value={item?.product_id}>
                {item?.product?.product_title}
              </option>
            ))}
          </select>
        </label>
        <textarea
          name="message"
          onChange={(e) => setMessage(e.target.value)}
          value={message}
          className="mt-4 h-36 input-base form-textarea"
          placeholder="Write your comment..."
          required
        />
        <button
          onClick={handleRating}
          className="px-6 h-12 bg-skyBlue rounded-[3px] text-white text-sm font-bold flex items-center justify-center mt-10"
        >
          ADD REVIEW
        </button>
      </div>
    </Modal>
  );
};

export default ReviewModal;

"use client";

import { Rating as ReactRating, Star } from "@smastrom/react-rating";
import "@smastrom/react-rating/style.css";

const StarRating = ({ value }) => {
  const myStyles = {
    itemShapes: Star,
    itemStrokeWidth: 2,
    activeFillColor: "#FA8232",
    activeStrokeColor: "#FA8232",
    inactiveFillColor: "#FFFFFF",
    inactiveStrokeColor: "#ADB7BC",
  };

  return (
    <ReactRating
      style={{ maxWidth: 100 }}
      value={value}
      itemStyles={myStyles}
      readOnly
    />
  );
};

export default StarRating;

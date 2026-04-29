import getParsedJson from "@/utils/getParsedJson";

const Specification = ({ data }) => {
  const specification = getParsedJson(data?.additional_info?.specification);
  return (
    <div className="p-10 flex flex-col">
      {specification?.map((item, i) => (
        <div
          key={i}
          className="grid grid-cols-[2fr_2px_3fr] gap-6 py-3 border-t border-border last:border-b border-dashed"
        >
          <p>{Object.keys(item)}</p>
          <span>:</span>
          <p>{Object.values(item)}</p>
        </div>
      ))}
    </div>
  );
};

export default Specification;

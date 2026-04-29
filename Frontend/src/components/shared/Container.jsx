const Container = ({ children, className }) => {
  return (
    <div className={`max-w-screen-2xl h-full mx-auto px-4 ${className}`}>
      {children}
    </div>
  );
};

export default Container;

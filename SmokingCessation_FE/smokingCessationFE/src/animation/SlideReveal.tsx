import { motion, useAnimation, useInView } from "framer-motion";
import { useEffect, useRef } from "react";

interface Props {
    children: React.ReactNode;
    width?: "fit-content" | "100%";
    overflow?: "hidden" | "";
}

export const SlideReveal = ({ children, width = "100%", overflow ="" }: Props) => {
    const ref = useRef<HTMLDivElement>(null);
    const isInView = useInView(ref, { once: true });
    const mainControls = useAnimation();
    const slideControls = useAnimation();
    useEffect(() => {
        console.log("isInView:", isInView);  // Log isInView to verify if it's changing
        if (isInView) {
            mainControls.start("visible");
            slideControls.start("visible");
        }
    }, [isInView, mainControls]);

    return (
        <div ref={ref} style={{ position: "relative", width, overflow }}>
            <motion.div
                variants={{
                    hidden: { opacity: 0, y: 75 },
                    visible: { opacity: 1, y: 0 },
                }}
                initial="hidden"
                animate={mainControls}
                transition={{ duration: 0.5, delay: 0.25 }}
            >
                {children}
            </motion.div>
            <motion.div
            variants={{
                hidden: {left: 0},
                visible: {left: "100%"},
            }}
            initial="hidden"
            animate={slideControls}
            transition={{ duration: 0.5, ease: "easeIn"}}
            style={{
                position: "absolute",
                top: 4,
                bottom: 4,
                left: 0,
                right: 0,
                background: "#E5BC69",
                zIndex: 20,
            }}
            />
        </div>
    );
};
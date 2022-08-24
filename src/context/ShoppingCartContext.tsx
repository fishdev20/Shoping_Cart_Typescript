import { createContext, ReactNode, useContext, useState } from "react";
import ShoppingCart from "../components/ShoppingCart";
import { useLocalStorage } from "../hooks/useLocalStorage";


type ShoppingCardProviderProps = {
    children: ReactNode
}

type ShoppingCardContext = {
    openCart: () => void
    closeCart: () => void
    cartQuantity: number
    cartItems: CartItem[]
    getItemQuantity : (id: number) => number
    increaseCartQuantity : (id: number) => void
    decreaseCartQuantity : (id: number) => void
    removeFromCart : (id: number) => void
}

type CartItem = {
    id: number,
    quantity: number
}


const ShoppingCardContext = createContext({} as ShoppingCardContext)

export function useShoppingCart() {
    return useContext(ShoppingCardContext)
}

export function ShoppingCardProvider({ children }: ShoppingCardProviderProps) {

    const [cartItems,setCartItems] = useLocalStorage<CartItem[]>("shopping-cart",[])
    const [isOpen,setIsOpen] = useState(false)

    const openCart = () => setIsOpen(true)
    const closeCart = () => setIsOpen(false)

    const cartQuantity = cartItems.reduce(
        (quantity, item) => item.quantity + quantity,0
    )

    const getItemQuantity = (id: number) => {
        return cartItems.find(item => item.id === id)?.quantity || 0
    }

    const increaseCartQuantity = (id: number) => {
        setCartItems(currItems => {
            if(currItems.find(item => item.id === id) == null) {
                return [...currItems, {id,quantity: 1}]
            } else {
                return currItems.map(item => {
                    if(item.id === id) {
                        return {...item,quantity: item.quantity + 1}
                    } else return item
                })
            }
        })
    }

    const decreaseCartQuantity = (id: number) => {
        setCartItems(currItems => {
            if(currItems.find(item => item.id === id)?.quantity == 1) {
                return currItems.filter(item => item.id !== id)
            } else {
                return currItems.map(item => {
                    if(item.id === id) {
                        return {...item,quantity: item.quantity - 1}
                    } else return item
                })
            }
        })
    }
    const removeFromCart = (id: number) => {
        setCartItems(currItems => {
            return currItems.filter(item => item.id !== id)
        })
    }
    return (
    <ShoppingCardContext.Provider 
        value={{ 
            getItemQuantity, 
            increaseCartQuantity, 
            decreaseCartQuantity, 
            removeFromCart,
            cartItems,
            cartQuantity,
            openCart,
            closeCart
        }}
    > 
        {children}
        <ShoppingCart isOpen={isOpen}/>
    </ShoppingCardContext.Provider>
    )
}